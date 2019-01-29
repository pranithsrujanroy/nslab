BEGIN{
	sent = 0;
	received = 0;
	for(i=0;i<10000;i++){
		s_time[i]=-1;
		r_time[i]=-1;
	}
	delay = 0;
	count = 0;
}
{	
	time = $3
	if($1=="s" && $19 == "AGT"){
		sent++;
		if(!startTime || time < startTime){
			startTime = time;
		} 
		s_time[$47] = time
	}
	else if($1 == "r" && $19 == "AGT"){
		received++;
		if(time > stopTime){
			stopTime = time;
		}
		data += $37
		r_time[$47] = time
	}
}
END{

	for(i=0; i< received;i++){
		if(s_time[i]!=-1 && r_time[i]!=1){
			delay += (r_time[i]-s_time[i]);
			count++;
		}
	}
	ed = delay/count;
	printf("Packet delivery ratio %.2f\n", (received/sent)*100);
	printf("Throughput %.2f\n", ((received*512)/(stopTime-startTime))*(8/1000));
	printf("End to end delay %.2f\n", ed);
}
