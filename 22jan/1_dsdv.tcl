#defining network parameters for static nodes
set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(ant) Antenna/OmniAntenna
set val(ll) LL
set val(ifq) Queue/DropTail/PriQueue
set val(ifqlen) 50
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(rp) DSDV
set val(nn) 2
set val(x) 500
set val(y) 500

set ns [new Simulator]
set rng [new RNG]
$rng seed next-substream

set tr [open 1_dsdv.tr w]
$ns trace-all $tr

set namtr [open 1_dsdv.nam w]
$ns namtrace-all-wireless $namtr $val(x) $val(y)

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)
$ns node-config -addressingType flat \
				-adhocRouting $val(rp) \
				-llType $val(ll) \
				-macType $val(mac) \
				-ifqType $val(ifq) \
				-ifqLen $val(ifqlen) \
				-antType $val(ant) \
				-propType $val(prop) \
				-phyType $val(netif) \
				-topoInstance $topo \
				-channelType $val(chan) \
				-agentTrace ON \
				-routerTrace ON \
				-macTrace OFF \
				-movementTrace OFF
				
for {set i 0} {$i < $val(nn) } {incr i} {
	set node($i) [$ns node]
	$node($i) random-motion 0
}

for {set i 0} {$i < $val(nn)} {incr i} {
	set xx [$rng uniform 0.0 500.0]
	set yy [$rng uniform 0.0 500.0]
	$node($i) set X_ $xx
	$node($i) set Y_ $yy
	$node($i) set Z_ 0.0
}

for {set i 0} {$i < $val(nn)} { incr i } {
# 30 defines the node size for nam
$ns initial_node_pos $node($i) 30
}

set tcp [new Agent/TCP]
set sink [new Agent/TCPSink]
$ns attach-agent $node(0) $tcp
$ns attach-agent $node(1) $sink
$ns connect $tcp $sink
$tcp set packetSize_ 1024

set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set packetSize_ 1024
$ftp set rate_ 1Mb

$ns at 1.0 "$ftp start"
$ns at 10.0 "$ftp stop"

$ns at 50.0 "$ns halt"
$ns run 
