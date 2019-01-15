set ns [new Simulator]
$ns multicast

set f [open multi.tr w]
$ns trace-all $f
$ns namtrace-all [open multi.nam w]

$ns color 1 red
$ns color 30 purple
$ns color 31 green

# allocate a multicast address;
set group [Node allocaddr]                   

set nod 5                         

# create multicast capable nodes;
for {set i 1} {$i <= $nod} {incr i} {
   set n($i) [$ns node]                      
}

#Create links between the nodes
$ns duplex-link $n(1) $n(2) 0.3Mb 10ms DropTail
$ns duplex-link $n(2) $n(3) 0.3Mb 10ms DropTail
$ns duplex-link $n(3) $n(4) 0.3Mb 10ms DropTail
$ns duplex-link $n(2) $n(5) 0.3Mb 10ms DropTail

$ns duplex-link-op  $n(1) $n(2) orient right
$ns duplex-link-op  $n(2) $n(3) orient right
$ns duplex-link-op $n(3) $n(4) orient up
$ns duplex-link-op $n(2) $n(5) orient up

# configure multicast protocol;
set mproto CtrMcast
# all nodes will contain multicast protocol agents;
set mrthandle [$ns mrtproto $mproto]         

$mrthandle set_c_rp $n(5)

set udp1 [new Agent/UDP]                     
set udp2 [new Agent/UDP]                    

$ns attach-agent $n(1) $udp1
$ns attach-agent $n(2) $udp2

set src1 [new Application/Traffic/CBR]
$src1 attach-agent $udp1
$udp1 set dst_addr_ $group
$udp1 set dst_port_ 0

set src2 [new Application/Traffic/CBR]
$src2 attach-agent $udp2
$udp2 set dst_addr_ $group
$udp2 set dst_port_ 1

# create receiver agents
set rcvr [new Agent/LossMonitor]      

# joining and leaving the group;
$ns at 0.6 "$n(3) join-group $rcvr $group"
$ns at 1.3 "$n(4) join-group $rcvr $group"
$ns at 1.6 "$n(5) join-group $rcvr $group"
$ns at 1.9 "$n(4) leave-group $rcvr $group"
$ns at 2.3 "$n(3) join-group $rcvr $group"

$ns at 0.4 "$src1 start"
$ns at 2.0 "$src2 start"

$ns at 4.0 "finish"

proc finish {} {
        global ns
        $ns flush-trace
        exec nam multi.nam &
        exit 0
}

$ns run

