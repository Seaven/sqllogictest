#!/usr/bin/tclsh
#
# Run this script in the "src" subdirectory of sqllogictest, after first
# compiling the ./sqllogictest binary, in order to verify correct output
# of all historical test cases.
#

set starttime [clock seconds]

set BIN ./sqllogictest
if {![file exec $BIN]} {
  error "$BIN does not exist or is not executable.  Run make."
}

# add all test case file in the $subdir subdirectory to the
# set of all test case files in the global tcase() array.
#
proc search_for_test_cases {subdir} {
  foreach nx [glob -nocomplain $subdir/*] {
    if {[file isdir $nx]} {
      search_for_test_cases $nx
    } elseif {[string match *.test $nx]} {
      set ::tcase($nx) 1
    }
  }
}
search_for_test_cases ../doris_test

set size [array size tcase]
puts "test file size $size"

# Run the tests
#
set totalerr 0
set totaltest 0
set totalrun 0
foreach tx [lsort [array names tcase]] {
  catch {
    exec $BIN -odbc "DSN=wangrui;" -verify $tx
  } res
  puts $res
  if {[regexp {(\d+) errors out of (\d+) tests} $res all nerr ntst]} {
    incr totalerr $nerr
    incr totaltest $ntst
  } else {
    error "test did not complete: $BIN -verify $tx"
  }
  incr totalrun
}

set endtime [clock seconds]
set totaltime [expr {$endtime - $starttime}]
puts "$totalerr errors out of $totaltest tests and $totalrun invocations\
      in $totaltime seconds"
