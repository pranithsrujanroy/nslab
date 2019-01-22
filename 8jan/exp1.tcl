set ns [new Simulator]

set tr [open exp1.tr w]
$ns trace-all $tr

set namtr [open exp1.nam w]
$ns namtrace-all $namtr 

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

$ns duplex-link $n0 $n1 10Mb 5ms DropTail
$ns duplex-link $n2 $n0 10Mb 5ms DropTail
$ns duplex-link $n3 $n0 10Mb 5ms DropTail
$ns duplex-link $n4 $n1 10Mb 5ms DropTail
$ns duplex-link $n5 $n1 10Mb 5ms DropTail

$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n0 $n2 orient left-up
$ns duplex-link-op $n0 $n3 orient left-down
$ns duplex-link-op $n1 $n4 orient right-up
$ns duplex-link-op $n1 $n5 orient right-down

$ns at 50.0 "$ns halt"
$ns run

