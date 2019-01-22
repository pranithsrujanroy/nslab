set ns [new Simulator]

$ns color 1 Blue
$ns color 2 Red

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

$ns duplex-link $n0 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 300Kb 100ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n3 $n4 500Kb 40ms DropTail
$ns duplex-link $n3 $n5 500Kb 30ms DropTail

$ns duplex-link-op $n2 $n0 orient left-up
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n2 $n1 orient left-down
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n3 $n5 orient right-down

set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
$tcp0 set packetSize_ 1024

set sink0 [new Agent/TCPSink]
$ns attach-agent $n4 $sink0

$ns connect $tcp0 $sink0
$tcp0 set fid_ 1

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ftp0 set packetSize_ 1024
$ftp0 set rate_ 1Mb

$ns at 1.0 "$ftp0 start"
$ns at 5.0 "$ftp0 stop"

set udp0 [new Agent/UDP]
$ns attach-agent $n1 $udp0

set null0 [new Agent/Null]
$ns attach-agent $n5 $null0

$ns connect $udp0 $null0
$udp0 set fid_ 2

set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set packetSize_ 1024
$cbr0 set rate_ 1Mb

$ns at 1.0 "$cbr0 start"
$ns at 5.0 "$cbr0 stop"

$ns at 50.0 "$ns halt"
$ns run
