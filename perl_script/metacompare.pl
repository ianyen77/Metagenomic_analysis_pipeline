for ($x=0; $x< @ARGV; $x++){
	if ($ARGV[$x] =~ /(\S+\/)(\S+)(final.contigs)/){
	$filename=$2;
	}  
	$contig=$filename."final.contigs";
	$gene=$filename.".nucl";
	system("./metacmp.py -c $contig -g $gene -t 16");
	}
