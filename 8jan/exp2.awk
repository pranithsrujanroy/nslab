BEGIN{
	cbr_sent = 0;
	cbr_rec = 0;
	tcp_send = 0;
	tcp_rec = 0;
}

{
	if($1=="+"&&$3==3&&$4==0&&$5=="cbr"){
		cbr_sent++;
	}
	if($1=="r"&&$3==1&&$4==5&&$5=="cbr"){
		cbr_rec++;
	}
	if($1=="+"&&$3==2&&$4==0&&$5=="tcp"){
		tcp_sent++;
	}
	if($1=="r"&&$3==1&&$4==4&&$5=="tcp"){
		tcp_rec++;
	}
}

END{
	printf("CBR packets sent by node 3: %d\n", cbr_sent);
	printf("CBR packets received by node 5: %d\n", cbr_rec);
	printf("TCP packets sent by node 2: %d\n", tcp_sent);
	printf("TCP packets received by node 4: %d\n", tcp_rec);
}
