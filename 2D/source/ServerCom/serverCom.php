<?php
	//$json = json_encode($_REQUEST);
	$file = 'leaderboard.txt';
	
	
			
	$current_data = file_get_contents($file);
	$array_data = json_decode($current_data, true);
	
	$player_Name = $_REQUEST['name'];
	$player_score = $_REQUEST['score'];
	
	if($player_Name != NULL && $player_score != NULL)
	{
		//$array_data[$player_Name] = $player_score;
	
		if ( isset($array_data[$player_Name] ) ) 
		{ 
			//print ("Yes it's there!");
			if ( $array_data[$player_Name] <= $player_score )
			{
				$array_data[$player_Name] = $player_score;//only set if bigger
			}
		} else {
			//print ("not found");
			$array_data[$player_Name] = $player_score;
		}
		
	}
	
	
	arsort($array_data);//sort for the score
	
	while(sizeof($array_data) > 10){
		array_pop($array_data);
	}
	
	$data_proccesed = json_encode($array_data, JSON_PRETTY_PRINT);
	
	file_put_contents($file, $data_proccesed);//put to file

			
	print($data_proccesed);//send back
?>