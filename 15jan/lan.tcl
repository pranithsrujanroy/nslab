set ns [new Simulator]
#define color for data flows
$ns color 1 Blue
$ns color 2 Red
#open tracefiles
set lan_tr [open lan_tr.tr w]
$ns trace-all $lan_tr
#open nam file
set lan_namtr [open lan_namtr.nam w]
$ns namtrace-all $lan_namtr
#define the finish procedure
proc finish {} {
	global ns lan_tr lan_namtr
	$ns flush-trace
	close $lan_tr
	close $lan_namtr
	exec nam lan_namtr.nam &
	exit 0
	} 
#create six nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]


#create links between the nodes
$ns duplex-link $n0 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns simplex-link $n2 $n5 0.3Mb 50ms DropTail
$ns simplex-link $n5 $n2 0.3Mb 50ms DropTail
$ns duplex-link $n1 $n7 1Mb 10ms DropTail
set lan [$ns newLan "$n3 $n4 $n5 $n6" 0.5Mb 40ms LL Queue/DropTail MAC/Csma/Cd Channel]

#Give node position
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns simplex-link-op $n2 $n5 orient left
$ns simplex-link-op $n5 $n2 orient left
$ns duplex-link-op $n1 $n7 orient down
#set queue size of link(n2-n3) to 20
$ns queue-limit $n2 $n5 20

#setup TCP connection
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink
$ns connect $tcp $sink
$tcp set fid_ 1
$tcp set packet_size_ 512

#set ftp over tcp connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp

#setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set null [new Agent/Null]
$ns attach-agent $n3 $null
$ns connect $udp $null
$udp set fid_ 2

#setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1024
$cbr set rate_ 1Mb

#scheduling the events
$ns at 1.0 "$cbr start"
$ns at 3.0 "$ftp start"
$ns at 8.0 "$ftp stop"
$ns at 4.0 "$cbr stop"
$ns at 10.0 "$ns halt"
$ns run
