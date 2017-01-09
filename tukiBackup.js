var pricesWeek =   [250.00,  500.00,  750.00,  1000.00,  1250.00,  1500.00,  1750.00,  2000.00,  2250.00,  2500.00,  2750.00,  3000.00,  3250.00,  3500.00,  3700.00,  3900.00,  4100.00,  4300.00,  4500.00,  4700.00,  4900.00,  5100.00,  5300.00,  5500.00,  5700.00,  5900.00,  6108.23,  6318.38,  6527.05,  6724.05,  6919.32,  7102.70,  7252.70,  7413.77,  7563.77,  7713.77,  7863.77,  8013.77,  8163.77,  8313.77,  8463.77,  8615.68,  8776.17,  8931.04,  9087.83,  9244.61,  9397.50,  9542.33,  9683.59,  9827.88,  9966.79,  10105.19,  10244.40,  10380.75,  10516.85,  10651.22,  10785.95,  10918.69,  11051.31,  11179.93,  11319.18,  11448.99,  11586.35,  11712.56,  11841.93,  11969.44,  12096.51,  12223.65,  12350.36,  12479.50,  12604.40,  12728.22,  12852.40,  12983.47,  13111.01,  13232.47,  13355.32,  13479.11,  13599.20,  13717.93,  13837.41,  13958.03,  14076.80,  14194.00,  14313.11,  14430.57,  14548.03,  14664.31,  14783.96,  14899.30,  15014.01,  15130.04,  15243.72,  15358.41,  15472.17,  15584.76,  15696.87,  15811.77,  15923.89,  16035.12,  16146.92,  16257.58,  16368.10,  16479.05,  16587.77,  16696.41,  16811.10,  16918.21,  17025.02,  17133.78,  17242.76,  17347.67,  17451.02,  17550.98,  17656.51,  17759.11,  17857.56,  17954.80,  18045.87,  18137.13] 
var pricesWeekend = [250.00,  500.00,  750.00,  1000.00,  1250.00,  1500.00,  1750.00,  2000.00,  2200.00,  2400.00,  2600.00,  2800.00,  3000.00,  3200.00,  3400.00,  3600.00,  3800.00,  4000.00,  4200.00,  4400.00,  4600.00,  4800.00,  5000.00,  5200.00,  5400.00,  5600.00,  5791.54,  5977.16,  6160.65,  6337.23,  6512.87,  6684.53,  6855.34,  7019.45,  7176.52,  7329.86,  7476.48,  7627.60,  7775.09,  7915.63,  8050.93,  8183.47,  8318.18,  8444.19,  8570.77,  8696.08,  8822.44,  8930.72]
var kmWeek =   [7.05,  14.38,  22.91,  32.13,  42.85,  53.91,  65.09,  76.48,  87.98,  99.67,  111.37,  123.55,  137.44,  152.27,  160.32,  169.22,  178.39,  187.89,  197.75,  209.95,  220.97,  233.32,  245.38,  257.40,  270.07,  281.71,  301.56,  322.91,  349.51,  369.66,  400.78,  419.34,  427.58,  441.82,  450.80,  460.07,  468.81,  478.37,  487.79,  497.10,  507.32,  520.93,  542.17,  558.53,  579.68,  602.86,  621.65,  635.78,  648.92,  663.55,  675.90,  688.46,  701.56,  713.61,  726.19,  738.58,  751.23,  763.53,  775.93,  787.10,  805.90,  819.59,  837.94,  848.70,  862.45,  874.04,  885.54,  897.30,  909.02,  922.66,  934.35,  945.62,  958.44,  975.03,  989.54,  1000.28,  1012.02,  1024.59,  1035.49,  1046.61,  1057.51,  1069.85,  1081.69,  1091.84,  1103.29,  1115.10,  1126.88,  1137.97,  1150.76,  1161.34,  1171.75,  1183.56,  1193.58,  1204.19,  1214.55,  1224.66,  1234.64,  1246.33,  1256.88,  1267.03,  1277.53,  1287.35,  1297.31,  1308.51,  1318.43,  1328.32,  1345.10,  1354.80,  1365.15,  1376.08,  1387.20,  1396.79,  1406.53,  1414.99,  1427.47,  1438.22,  1446.83,  1457.13,  1465.54,  1475.39]
var kmWeekEnd =   [8.47,  17.30,  26.48,  36.32,  47.17,  58.02,  69.38,  81.41,  89.19,  97.95,  107.54,  117.19,  127.36,  137.73,  148.62,  159.73,  171.22,  183.31,  195.81,  208.36,  221.84,  235.38,  249.74,  264.66,  279.90,  295.88,  317.24,  337.53,  358.03,  375.66,  393.33,  410.32,  427.20,  444.13,  462.07,  480.18,  494.54,  512.22,  527.30,  541.11,  554.71,  568.04,  583.39,  595.35,  607.85,  619.97,  634.21,  644.91]
var calculatedValues = [0,0,0,0]
var isNaphta = false;

function validateInputs(weekHours, weekEndHours, fuelType, fuelPerformance){
	var shouldReturn = false;


	if (fuelType == null){
		$("#fuelType").css("color", "red");
		$("#typeError").show()
		shouldReturn = true
	} else {
		$("#typeError").hide()
		$("#fuelType").css("color", "#000000");
	}

	if (fuelPerformance == null){
		$("#fuelPerformance").css("color", "red");
		$("#performanceError").show()
		shouldReturn = true
	} else {
		$("#fuelPerformance").css("color", "#000000");
		$("#performanceError").hide()
	}
	return shouldReturn
}

function getPricePerKm(fuelType, fuelPerformance){
	var pricePerKmFuel
	if (fuelType.includes("Nafta")){
		if (fuelPerformance.includes("Alt")){
			pricePerKmFuel = 1.29
		}
		if (fuelPerformance.includes("Med")){
			pricePerKmFuel = 1.8
		}
		if (fuelPerformance.includes("Baj")){
			pricePerKmFuel = 2.57
		}
	} else {
		if (fuelPerformance.includes("Alt")){
			pricePerKmFuel = 0.71
		}
		if (fuelPerformance.includes("Med")){
			pricePerKmFuel = 1
		}
		if (fuelPerformance.includes("Baj")){
			pricePerKmFuel = 1.43
		}
	}
	return pricePerKmFuel
}

function checkAndScrollToTop(weekHours, weekEndHours, fuelType, fuelPerformance){
	if (calculatedValues[0] == weekHours && calculatedValues[1] == weekEndHours && calculatedValues[2] == fuelType && calculatedValues[3] == fuelPerformance){

	 $('html, body').animate({
        scrollTop: $("#element-214").offset().top - 80
    }, 1000);

		return true
	}
	return false
}

function calculatePrice(){
	var weekHours = ijQuery("#weekHours").val()
	var weekEndHours = ijQuery("#weekEndHours").val()
	var fuelType = $(document.getElementById('fuelType')).val()
	var fuelPerformance = $(document.getElementById('fuelPerformance')).val()


	if (checkAndScrollToTop(weekHours, weekEndHours, fuelType, fuelPerformance)){
		return
	}

	if (validateInputs(weekHours, weekEndHours, fuelType, fuelPerformance)) {
		$('#spacerdiv').show();
		return
	}

	if (weekHours == ""){
		$('#weekHours').val('0')
		weekHours = 0
	}
	if (weekEndHours == ""){
		weekEndHours = 0
		$('#weekEndHours').val('0')
	}

	 $('html, body').animate({
        scrollTop: $("#fuelPerformance").offset().top - 80
    }, 1000);




	var pricePerKmFuel = getPricePerKm(fuelType, fuelPerformance)
	
	var weekRevenue
	var weekEndRevenue
	var weekKm 
	var weekEndKm 

	if (weekHours>120){
		weekRevenue = pricesWeek[119]
		weekKm = kmWeek[119]
	} else {
		if (weekHours>0){
			weekKm = kmWeek[weekHours - 1]
			weekRevenue = pricesWeek[weekHours-1]
		} else {
			weekKm = 0
			weekRevenue = 0
		}
	}

	if (weekEndHours>48){
		weekEndRevenue = pricesWeekend[47]
		weekEndKm = kmWeekEnd[47]
	} else {
		if (weekEndHours>0){
			weekEndKm = kmWeekEnd[weekEndHours-1]
			weekEndRevenue = pricesWeekend[weekEndHours-1]
		} else {
			weekEndKm = 0
			weekEndRevenue = 0
		}
	}

	var totalPriceKms = pricePerKmFuel * totalKms
	var totalPriceWeek = (weekRevenue + weekEndRevenue - (( weekKm + weekEndKm ) * pricePerKmFuel) - ((weekRevenue + weekEndRevenue)*0.25)).toFixed(0)
	var $priceWeekHtml = $('#element-521').children()
	var totalKms = weekKm + weekEndKm


	while( $priceWeekHtml.length ) {
	  $priceWeekHtml = $priceWeekHtml.children();
	}
	gradualIncrease($priceWeekHtml.end(), totalPriceWeek)

	calculatedValues = [weekHours, weekEndHours, fuelType, fuelPerformance]
}


ijQuery(document).ready(function(){
	 $(".custinp").keydown(function (e) {
        // Allow: backspace, delete, tab, escape, enter and .
        if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190]) !== -1 ||
             // Allow: Ctrl+A
            (e.keyCode == 65 && e.ctrlKey === true) ||
             // Allow: Ctrl+C
            (e.keyCode == 67 && e.ctrlKey === true) ||
             // Allow: Ctrl+X
            (e.keyCode == 88 && e.ctrlKey === true) ||
             // Allow: home, end, left, right
            (e.keyCode >= 35 && e.keyCode <= 39)) {
                 // let it happen, don't do anything
                 return;
        }
        var clength
        if ($(this).attr('id') == 'weekHours'){
        	clength = 2
        	
        } else {
        	clength = 1
        }
        // Ensure that it is a number and stop the keypress
        if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105) || $(this).val().length > clength) {
            e.preventDefault();
        }

    });

	ijQuery('#calculate').click(function(){
		calculatePrice();
	})

	ijQuery('.customselect').change(function(){
		$(this).css("color", "#000000")
		if ($(this).attr('id') == 'fuelType'){
			$("#typeError").hide()
			var type = $(this).val()
			if (type.includes("Gas")){
				$('#highr').text('Alto (7 litros los 100km.)')
				$('#medr').text('Medio (9,5 litros los 100km.)')
				$('#lowr').text('Bajo (13 litros los 100km.)')
			} else { 
				$('#highr').text('Alto (8 litros los 100km.)')
				$('#medr').text('Medio (10 litros los 100km.)')
				$('#lowr').text('Bajo (14 litros los 100km.)')
			}
		} else {

			$("#performanceError").hide()
		}
	})

	ijQuery('.custinp').keyup(function(){
		 if ($(this).attr('id') == 'weekHours'){
        	if ($(this).val()>120){
        		$(this).val('120')
        	}
        } else {
        	if ($(this).val()>48){
        		$(this).val('48')
        	}
        }
	})

	ijQuery('.custinp').keypress(function(){
		if ($(this).attr('id') == 'weekHours'){
			$("#weekError").hide()
		} else {
			$("#weekEndError").hide()
		}
	})
})


function gradualIncrease(htmlInput, numberToReach){
	var number = 0;
	 var interval = setInterval(function() {
        htmlInput.html("$" + number);
        if (number >= numberToReach){
        	$('#calculate').text("Volver a calcular")
        	clearInterval(interval);	
        } 

        if (numberToReach-450 <= number){
        	number+=1;
        } else {
        	number+=45;
        }
    }, 2);
	
}