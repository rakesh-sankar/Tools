<?php
# An Example of Forking or Parallel Processing in PHP

# Execute this command in CLI environment than WEB, make sure the PHP is configured
# with --enable-pcntl option.

set_time_limit(0);

# sample array with some strings to keep the LOOP
$tmpArray = array ("string 1", "string 2", "string 3", "string 4", "string 5");

# initialize a variable used to keep track of childrens
$childs = 0;
foreach ($tmpArray as $tmp) {
    # increment the childrens when it is created.
    $childs++;
    
    # start the child processes
    $childStart = pcntl_fork();
    
    # "0" - children area, do something here.
    if ($childStart == 0) {
        sleep(rand(3,9));

        # add some piece of code that you want to make it run parallely        
        print "Childresn Here.\n";
        
        exit (0);
    }
    
    # display the process-id (pid) of the parent process of a child
    print "Mum's the parent of $childStart\n";
}

# clean-up all parent process whose children is dead (means completed it's job).
for ($k=0; $k<$childs; $k++) {
    # read the status of the children process.
    $childStatus = pcntl_wait($status);
    
    print "Status of $childStatus children is $status.\n";
}
?>
