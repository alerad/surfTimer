<?php
/**
* Do not edit this file unless you know what you are doing.
**/

// Get configs
include 'config.php';

// Get input from user and trim it
$tCount[1] = $_POST['tier-1'];
$tCount[2] = $_POST['tier-2'];
$tCount[3] = $_POST['tier-3'];
$tCount[4] = $_POST['tier-4'];
$tCount[5] = $_POST['tier-5'];
$tCount[6] = $_POST['tier-6'];
$maps = explode("\n", $_POST['maps']);
$maps = array_map('trim', $maps);

// Connect to the database
if (DB === "MYSQL")
{
	$db = new mysqli($DB_ADDRESS, $DB_USER, $DB_PASS, $DB_DATABASE);

	if ($db->connect_errno > 0)
	    die('Unable to connect to database [' . $db->connect_error . ']');

} else if (DB === "SQLITE")
{
	try {
		$db = new SQLite3($DB_PATH);
	} catch (Exception $exception) {
		echo $exception->getMessage();
	}
}

// Prepare SQL-query
$sql = <<<SQL
SELECT mapname, count(CASE WHEN zonetype = 3 THEN 1 ELSE NULL END)+1 AS stages, (SELECT tier FROM ck_maptier b WHERE b.mapname = a.mapname) AS tier, count(DISTINCT zonegroup)-1 AS bonuses
FROM ck_zones a
GROUP BY mapname
ORDER BY tier ASC;
SQL;

// Query
if(!$result = $db->query($sql))
    die('There was an error running the query [' . $db->error . ']');

// Initialize result site
echo "<br>
<strong>umc-mapcycle.txt</strong>
<hr />
<pre>
\"umc_mapcycle\"
{";

// Initialize variables
$tier = -1;
$mapCycleSize = 0;
$stages;
$bonuses;
$tierString;

// Handle query on MySQL
if (DB === "MYSQL")
{
	while($row = $result->fetch_assoc()) {

		$key = array_search($row["mapname"], $maps);

		if ($key === FALSE) {
			continue;
		}

		if ($row["tier"] !== $tier) {

			if ($tier != -1)
				echo "
	}";

			if ($row["tier"] == NULL) {

				echo "
	\"Tier Unknown\"
	{";

			}
			else {

				echo "
	\"Tier ". $row["tier"] ."\"
	{
		\"maps_invote\" \"". $tCount[$row["tier"]] ."\"";

			}
			$tier = $row["tier"];
		}

		// Tier
		if ($row["tier"] === NULL)
			$tierString = "";
		else
			$tierString = "T". $row["tier"] ." ";

		// Stages
		if ($row["stages"] > 1) {
			$stages = $row["stages"] ."S";
		}
		else {
			$stages = "L";
		}

		// Bonuses
		if ($row["bonuses"] > 0)
		{
			if ($row["bonuses"] > 1) {
				$bonuses = " ". $row["bonuses"]. "B";
			}
			else {
				$bonuses = " B";
			}
		}
		else {
			$bonuses = "";
		}

		echo '
		"'. $row["mapname"] .'"		{ "display"		"'. $row["mapname"] .' ('.$tierString.''. $stages .''. $bonuses .')" }';

		unset($maps[$key]);

		$mapCycleSize++;
	}
	$result->free();
}
else if (DB === "SQLITE") //  Handle query on SQLite
{
	while($row = $result->fetchArray()) {

		$key = array_search($row["mapname"], $maps);

		if ($key === FALSE) {
			continue;
		}

		if ($row["tier"] !== $tier) {

			if ($tier != -1)
				echo "
	}";

			if ($row["tier"] == NULL) {

				echo "
	\"Tier Unknown\"
	{
		\"maps_invote\" \"2\"";

			}
			else {

				echo "
	\"Tier ". $row["tier"] ."\"
	{
		\"maps_invote\" \"2\"";

			}
			$tier = $row["tier"];
		}

		// Tier
		if ($row["tier"] === NULL)
			$tierString = "";
		else
			$tierString = "T". $row["tier"] ." ";

		// Stages
		if ($row["stages"] > 1) {
			$stages = $row["stages"] ."S";
		}
		else {
			$stages = "L";
		}

		// Bonuses
		if ($row["bonuses"] > 0)
		{
			if ($row["bonuses"] > 1) {
				$bonuses = " ". $row["bonuses"]. "B";
			}
			else {
				$bonuses = " B";
			}
		}
		else {
			$bonuses = "";
		}

		echo '
		"'. $row["mapname"] .'"		{ "display"		"'. $row["mapname"] .' ('.$tierString.''. $stages .''. $bonuses .')" }';

		unset($maps[$key]);

		$mapCycleSize++;
	}
	$result->finalize();
}

// Close DB-connection
$db->close();

// Finish results page
echo "
	}
}
</pre>";

echo "
<hr />
Maps in mapcycle: ". $mapCycleSize. "<br />";
if (count($maps) > 0)
{
	echo "<strong><font color=\"red\">Maps that were not found or were duplicates:</font><br />";
}

foreach($maps as $key)
{
  echo $key. "<br />";
}

echo "</strong>";

?>