#!/bin/bash
 
# Import the class definition file.
. ap.sh
 
function main()
{
    # Create the vectors objects. (1)
    AP 'ap1' o1:3f:33 Ololo -42 3
 
    # Call to it's methods.
    $ap1_show
	$ap1_connect
}
 
main
