#defining network parameters for static nodes
set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(ant) Antenna/OmniAntenna
set val(ll) LL
set val(ifq) Queue/DropTail/PriQueue
set val(ifqlen) 50
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(rp) DSR 
set val(nn) 50
set val(x) 500
set val(y) 500

set ns [new Simulator]
set rng [new RNG]
$rng seed next-substream
$ns use-newtrace
set tr [open dsr.tr w]
$ns trace-all $tr

set namtr [open dsr.nam w]
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
$ns initial_node_pos $node($i) 90
}

for {set i 1} {$i < $val(nn)} { incr i} {
	set udp($i) [new Agent/UDP]
	$ns attach-agent $node($i) $udp($i)
	
	set null($i) [new Agent/Null]
	$ns attach-agent $node(0) $null($i)
	
	$ns connect $udp($i) $null($i)
	
	set cbr($i) [new Application/Traffic/CBR]
	$cbr($i) attach-agent $udp($i)
	
	$cbr($i) set packetSize_ 512
	$cbr($i) set interval_ 0.1
	
	$ns at 1.0 "$cbr($i) start"
	$ns at 6.0 "$cbr($i) stop"
}

$ns at 50.0 "$ns halt"

$ns run 
