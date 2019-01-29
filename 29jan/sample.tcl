# Filename: sample33.tcl
# Simulator Instance Creation
set ns [new Simulator]

#Fixing the co-ordinate of simulation area
set val(x) 500
set val(y) 500
# Define options
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(nn) 3 ;# number of mobilenodes
set val(rp) AODV ;# routing protocol
set val(x) 500 ;# X dimension of topography
set val(y) 500 ;# Y dimension of topography
set val(stop) 10.0 ;# time of simulation end

# set up topography object
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

#Nam File Creation nam – network animator
set namfile [open sample33.nam w]

#Tracing all the events and cofiguration
$ns namtrace-all-wireless $namfile $val(x) $val(y)

#Trace File creation
set tracefile [open sample33.tr w]

#Tracing all the events and cofiguration
$ns trace-all $tracefile

# general operational descriptor- storing the hop details in the network
create-god $val(nn)

# configure the nodes
$ns node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-channelType $val(chan) \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF \
-movementTrace ON

# Node Creation

for {set i 0} {$i < 3} {incr i} {

set node_($i) [$ns node]
$node_($i) color black

}

#Location fixing for a single node

$node_(0) set X_ 258
$node_(0) set Y_ 222
$node_(0) set Z_ 0

for {set i 1} {$i < 3} {incr i} {

$node_($i) set X_ [expr rand()*$val(x)]
$node_($i) set Y_ [expr rand()*$val(y)]
$node_($i) set Z_ 0

}
# Label and coloring

for {set i 0} {$i < 3} {incr i} {

$ns at 0.1 "$node_($i) color blue"
$ns at 0.1 "$node_($i) label Node$i"

}
#Size of the node

for {set i 0} {$i < 3} {incr i} {

$ns initial_node_pos $node_($i) 30

}
#******************************Defining Communication Between node0 and all nodes ****************************8

for {set i 1} {$i < 3} {incr i} {

# Defining a transport agent for sending
set udp [new Agent/UDP]

# Attaching transport agent to sender node
$ns attach-agent $node_($i) $udp

# Defining a transport agent for receiving
set null [new Agent/Null]

# Attaching transport agent to receiver node
$ns attach-agent $node_(0) $null

#Connecting sending and receiving transport agents
$ns connect $udp $null

#Defining Application instance
set cbr [new Application/Traffic/CBR]

# Attaching transport agent to application agent
$cbr attach-agent $udp

#Packet size in bytes and interval in seconds definition
$cbr set packetSize_ 512
$cbr set interval_ 0.1

# data packet generation starting time
$ns at 1.0 "$cbr start"

# data packet generation ending time
#$ns at 6.0 "$cbr stop"

}
# ending nam and the simulation
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"

#Stopping the scheduler
$ns at 10.01 "puts \"end simulation\" ; $ns halt"
#$ns at 10.01 "$ns halt"

exec awk -f Throughput.awk sample33.tr > Throughput.xg &
exit 0
exec xgraph -geometry 500X500 -P -bg white -t THROUGHPUT -x time(s) -y throughput(Mbits/s) Throughput.xg &

#Starting scheduler
$ns run
