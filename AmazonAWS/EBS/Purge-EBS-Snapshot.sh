#!/usr/bin/php
<?php

// PHP SCRIPT TO REMOVE ALL BACKUPS OLDER THAN THE LAST X SNAPSHOT BACKUPS
// David Gildeh - 17/02/2010
// USAGE:
//       php remove_old_snapshots.php -v vol-id [-v vol-id ...] -n number
//          (where number is number of snapshots to keep per volume)
// EXAMPLE:
//       php remove_old_snapshots.php -v vol-assasas -v vol-asasas -n 99
//
// Original SRC from:
//    http://www.techkismet.com/systems-admin/automating-ec2-ebs-snapshot-cleanup.html


// PUT AWS VARIABLES HERE
define('AWS_ACCESS_KEY', '/home/path/pk-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.pem');
define('AWS_SECRET_ACCESS_CERT', '/home/path/cert-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.pem');

// Set debug
$debug = false;

// parse options (vol-ids, older-than)

$opts = getopt("v:n:");
// First get an array of volumes to 'prune'
if  (($opts['v']) && !is_array($opts['v']))
  $volumes_to_prune = array($opts['v']);
  else
    $volumes_to_prune = $opts['v'];

// Get n where n is the number of snapshots to keep for each volume
if ($opts['n'] == null) {
  // If no value given exit script with error
  print("ERROR: Please provide number of snapshots to keep (-n option)\n");
  exit;
}

if (!is_array($opts['n']))
{
  $keep_qty = $opts['n'];
  // Ensure minimum value is one
  if ($keep_qty < 1) {
    $keep_qty = 1;
  }
}

if ($debug)
{
  print("============\nInput parameters:\nVolumes to prune:\n");
  print_r($volumes_to_prune);
  print("Keep Quantity =  " . $keep_qty . "\n============\n");
}

// Get a list of the snapshots
$out = array();
#$cmd = 'ec2-describe-snapshots -K ' . AWS_ACCESS_KEY  . ' -C ' . AWS_SECRET_ACCESS_CERT . ' --region ' . AWS_REGION;
$cmd = 'ec2-describe-snapshots -K ' . AWS_ACCESS_KEY  . ' -C ' . AWS_SECRET_ACCESS_CERT;
exec($cmd, $out);

// Store each snapshot in it's own array element
$snaps = array();
foreach ($out as $snap) {
  // Notice the output above is separated by tabs.
  $snaps[] = explode("\t",$snap);
}

// convert to a unix timestamp
$inx = 0;   // counter
foreach ($snaps as $s) {
  $snaps[$inx][4] = strtotime($s[4]);
  $inx++;
}

// You can't really sort a PHP array on an element within the array without doing some tricks
// So here, we're going to turn the array inside out so we can sort on the volume
// and the timestamp
foreach ($snaps as $key => $row) {
  $column1[$key] = ($row[0]) ? $row[0] : "";
  $column2[$key] = ($row[1]) ? $row[1] : "";
  $column3[$key] = ($row[2]) ? $row[2] : "";
  $column4[$key] = ($row[3]) ? $row[3] : "";
  $column5[$key] = ($row[4]) ? $row[4] : "";
  $column6[$key] = ($row[5]) ? $row[5] : "";
}

// sort it
array_multisort($column3, SORT_ASC, $column5, SORT_DESC, $snaps);

// Now store a consolidated array of each volume with it's snapshots
// This will look like
$all_snaps = array();
foreach ($snaps as $s) {
  if (empty($all_snaps[$s[2]])) {
    $all_snaps[$s[2]] = $s[1];
  } else {
    $all_snaps[$s[2]] .= "," . $s[1];
  }
}

if($debug)
{
  print("The current array of snapshots ordered by date and volume:\n");
  print_r($all_snaps);
  print("==============\n");
}

// Since these are sorted from newest to oldest, we can go through these rows
// and delete all of the entries past the $keep_qty count

// Only process the volumes passed into the script
foreach ($volumes_to_prune as $volume_id) {

  if ($debug) {
    print("** Searching for volume " . $volume_id . "...\n");
  }

  if (array_key_exists($volume_id, $all_snaps)) {

    if ($debug) {
      print("Found volume " . $volume_id . "\n");
    }

    // Create an array of snapshots
    $snap_arr = explode(",",$all_snaps[$volume_id]);

    if ($debug) {
      print("============\nSnapshots for volume:\n");
      print_r($snap_arr);
    }

    // Only process volume if it has more snapshots than $keep_qty
    if (count($snap_arr) > $keep_qty) {

      print("INFO: Removing " . (count($snap_arr) - $keep_qty) . " snapshots for volume " . $volume_id . "\n");
      // Loop counter
      $count = 1;

      // Iterate through snapshots for this volume
      foreach ($snap_arr as $s) {
        if ($count <= $keep_qty) {
          print "** INFO: Keeping: $volume_id/ $s \n";
        } else {

          // Delete the snapshot, and print the output from the ec2-delete-snapshot command
          print "** INFO: Deleting: $volume_id/ $s\n";
          $out = array();
#          $cmd = 'ec2-delete-snapshot -K ' . AWS_ACCESS_KEY  . ' -C ' . AWS_SECRET_ACCESS_CERT . ' --region ' . AWS_REGION . ' ' . $s;
          $cmd = 'ec2-delete-snapshot -K ' . AWS_ACCESS_KEY  . ' -C ' . AWS_SECRET_ACCESS_CERT . ' ' . $s;
          exec($cmd, $out);
          print "** INFO: Output from command $cmd: \n";
          foreach ($out as $o) {
            print $o . "\n";
          }
        }
        $count++;
      }
    } else  {
      print("INFO: No snapshots were deleted for volume ". $volume_id . " as it has too few snapshots\n");
    }
  } else {
    print("WARNING: Could not find volume " . $volume_id . "\n");
  }
}

?>
