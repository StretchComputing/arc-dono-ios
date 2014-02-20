var CONFIRM_PAYMENT_TIMED_OUT = '1000';
var ARC = (function (r, $) {
  'use strict';

	r.serverUrl = null;
	r.baseUrl = null;

	r.createPaymentApiCodes = {
		106: "Username and/or Password incorrect, please try again"
	};

	r.confirmPaymentApiCodes = {
		106: "Username and/or Password incorrect, please try again"
	};

	r.urlParameters = [];

	// time is in milliseconds
	r.confirmInterval = [3000, 3000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 10000, 10000];
	r.confirmIntervalIndex = 0;
	r.ticketId = null;
	r.ccNumber = null;
	r.expirationDate = null;
	r.ccv = null;
	r.didComeFromPayment = "";
	r.donationAmount = "";
	r.chargedFee = "";
	r.name = "";
	r.isNewCardDropdown = "";
	r.cardArray=[];
	r.saveCard = "";
	r.ccToken = "";

	r.getCardTypeFromNumber = function GetCardType(number)
        {            
            var re = new RegExp("^4");
            if (number.match(re) != null)
                return "Visa";
 
            re = new RegExp("^(34|37)");
            if (number.match(re) != null)
                return "Amex";
 
            re = new RegExp("^5[1-5]");
            if (number.match(re) != null)
                return "MasterCard";
 
            re = new RegExp("^6011");
            if (number.match(re) != null)
                return "Discover";
 
            return "";
    }

	r.checkCardNumber = function valid_credit_card(value) {
	
	  // accept only digits, dashes or spaces
	if (/[^0-9-\s]+/.test(value)) return false;
 
		// The Luhn Algorithm. It's so pretty.
		var nCheck = 0, nDigit = 0, bEven = false;
		value = value.replace(/\D/g, "");
 
		for (var n = value.length - 1; n >= 0; n--) {
			var cDigit = value.charAt(n),
				nDigit = parseInt(cDigit, 10);
 
			if (bEven) {
				if ((nDigit *= 2) > 9) nDigit -= 9;
			}
 
			nCheck += nDigit;
			bEven = !bEven;
		}
 
		return (nCheck % 10) == 0;
	}
	



	r.createPayment = function() {
		try {
		

			//RSKYBOX.log.debug("sending a createPayment to server");
			console.log("sending a createPayment to server");
			var cpUrl = r.baseUrl + 'payments/create';
			var appInfo = { "App": "DONO", "OS": "IOS", "Version": "1.0" };
			var type = r.urlParameters['cardType'];
			var newType = "N";
			
			if (type == ""){

			}else{

				newType = type.charAt(0);
			}
			
			try{
				ARC.ccNumber = ARC.ccNumber.replace(/\s+/g, '');
				ARC.expirationDate = ARC.expirationDate.replace(/\s+/g, '');

			}catch (e){
			
			}
		
			
			var jsonData = {
				"AppInfo": appInfo,
				"InvoiceAmount": r.donationAmount,
				"Amount": r.donationAmount,
				"CustomerId": r.urlParameters['customerId'],
				"AuthenticationToken": r.urlParameters['authenticationToken'],
				"InvoiceId": r.urlParameters['invoiceId'],
				"MerchantId": r.urlParameters['merchantId'],
				"Gratuity": r.chargedFee,
				"Type": r.urlParameters['type'],
				"CardType": newType,
				"FundSourceAccount": ARC.ccNumber,
				"Expiration": ARC.expirationDate,
				"Pin": ARC.ccv,
				"Anonymous": r.urlParameters['anonymous'],
				"CreateBTAccount": ARC.saveCard,
				"CCToken": ARC.ccToken,
				"Items": r.buildItems()
			};
			//RSKYBOX.log.debug("createPayment jsonData = " + JSON.stringify(jsonData));
			console.log("createPayment jsonData = " + JSON.stringify(jsonData));
			r.confirmIntervalIndex = 0;

			$.ajax({
				dataType: 'json',
				contentType: 'application/json',
				type: 'POST',
				url: cpUrl,
				data: JSON.stringify(jsonData),
				headers: {'Authorization' : r.urlParameters['token']},
				//error: r.createPaymentError,
				success: r.createPaymentSuccess,
				statusCode: r.statusCodeHandlers(r.createPaymentApiError)
			});
		} catch (e) {
			//RSKYBOX.log.error(e, 'createPayment');
		}
	};

	r.createPaymentSuccess = function(data, status, jqXHR) {
		try {
			//RSKYBOX.log.debug("createPaymentSuccess entered, Success = " + data.Success);
			console.log("createPaymentSuccess entered, Success = " + data.Success);
			if(data.Success) {
				r.ticketId = data.Results;
				r.confirmPayment();
			} else {
				//RSKYBOX.log.debug("createPaymentSuccess failed with error code = " + data.ErrorCodes[i].Code);
				r.returnToIos('failure', null, data.ErrorCodes[i].Code);
			}
		} catch (e) {
			//RSKYBOX.log.error(e, 'createPaymentSuccess');
		}
	};

	// no "try again" scenario errors so always just return error to iOS app
	r.createPaymentApiError = function(jqXHR) {
		try {
			//RSKYBOX.log.debug("createPaymentApiError entered");
			console.log("createPaymentApiError entered");
			var code = r.getApiStatus(jqXHR.responseText);
			//RSKYBOX.log.info(code, 'createPaymentApiError');
			r.returnToIos('failure', null, code);
		} catch (e) {
			//RSKYBOX.log.error(e, 'createPaymentApiError');
		}
	};

	r.scheduleConfirmPayment = function(){
		//RSKYBOX.log.debug("scheduling confirm with index = " + confirmIntervalIndex + " for " + r.confirmInterval[r.confirmIntervalIndex] + " ms");
		console.log("scheduling confirm with index = " + r.confirmIntervalIndex + " for " + r.confirmInterval[r.confirmIntervalIndex] + " ms");
		setTimeout(
			function(){
				r.confirmPayment();
			}, r.confirmInterval[r.confirmIntervalIndex]);
	};

	r.confirmPayment = function() {
		try {
			//RSKYBOX.log.debug("sending a confirmPayment to server");
			console.log("sending a confirmPayment to server");
			var cpUrl = r.baseUrl + 'payments/confirm';
			var appInfo = { "App": "DONO", "OS": "IOS", "Version": "1.0" };
			var jsonData = {
				"AppInfo": appInfo,
				"TicketId": r.ticketId

			};
			//RSKYBOX.log.debug("confirmPayment jsonData = " + JSON.stringify(jsonData));
			console.log("confirmPayment jsonData = " + JSON.stringify(jsonData));

			$.ajax({
				dataType: 'json',
				contentType: 'application/json',
				type: 'SEARCH',
				url: cpUrl,
				data: JSON.stringify(jsonData),
				headers: {'Authorization' : r.urlParameters['token']},
				//error: r.confirmPaymentError,
				success: r.confirmPaymentSuccess,
				statusCode: r.statusCodeHandlers(r.confirmPaymentApiError)
			});
		} catch (e) {
			//RSKYBOX.log.error(e, 'confirmPayment');
		}
	};

	r.confirmPaymentSuccess = function(data, status, jqXHR) {
		try {
			//RSKYBOX.log.debug("confirmPaymentSuccess entered, Success = " + data.Success);
			console.log("confirmPaymentSuccess entered, Success = " + data.Success);


			if(data.Success) {
				// if anything in the Results field, that payment is complete
				if(data.Results && data.Results.PaymentId) {
					//RSKYBOX.log.debug("confirmPaymentSuccess payment is now complete");
					console.log("confirmPaymentSuccess payment is now complete");
					r.returnToIos('success', data.Results.PaymentId);
				} else {
					//RSKYBOX.log.debug("confirmPaymentSuccess payment is not yet complete, scheduling another confirmation to be sent");
					console.log("confirmPaymentSuccess payment is not yet complete, scheduling another confirmation to be sent");
					r.confirmIntervalIndex++;
					if(r.confirmIntervalIndex < r.confirmInterval.length) {
						r.scheduleConfirmPayment();
					} else {
						//RSKYBOX.log.debug("confirmPaymentSuccess failed be maximum number of confirms have been sent to server");
						console.log("confirmPaymentSuccess failed be maximum number of confirms have been sent to server");
						r.returnToIos('failure', null, CONFIRM_PAYMENT_TIMED_OUT);
					}
				}
			} else {
				//RSKYBOX.log.debug("confirmPaymentSuccess failed with error code = " + data.ErrorCodes[i].Code);
				console.log("confirmPaymentSuccess failed with error code = " + data.ErrorCodes[i].Code);
				r.returnToIos('failure', null, data.ErrorCodes[i].Code);
			}
		} catch (e) {
			//console.log("There was an exception thrown: " + e);
			//RSKYBOX.log.error(e, 'confirmPaymentSuccess');
		}
	};

	// no "try again" scenario errors so always just return error to iOS app
	r.confirmPaymentApiError = function(jqXHR) {
		try {
			//RSKYBOX.log.debug("confirmPaymentApiError entered");
			console.log("confirmPaymentApiError entered");
			var code = r.getApiStatus(jqXHR.responseText);
			//RSKYBOX.log.info(code, 'confirmPaymentApiError');
			r.returnToIos('failure', null, code);
		} catch (e) {
			//RSKYBOX.log.error(e, 'confirmPaymentApiError');
		}
	};

	r.getUrlParameters = function() {
		try {
			//RSKYBOX.log.debug("getUrlParameters entered");
			console.log("getUrlParameters entered");
			var urlParameters = {};
			var query = window.location.search.substring(1);
			var params = query.split("&");
			for (var i=0;i<params.length;i++) {
				var pair = params[i].split("=");
				var decodedValue = r.decodeUrlComponent(pair[1]);
				console.log("getUrlParameters(): pair[0] = " + pair[0]);
				console.log("getUrlParameters(): pair[1] = " + pair[1]);
				console.log("getUrlParameters(): decodedValue = " + decodedValue);
				// If first entry with this name
				if (typeof urlParameters[pair[0]] === "undefined") {
					urlParameters[pair[0]] = decodedValue;
					// If second entry with this name
				} else if (typeof urlParameters[pair[0]] === "string") {
					var arr = [ urlParameters[pair[0]], decodedValue ];
					urlParameters[pair[0]] = arr;
					// If third or later entry with this name
				} else {
					urlParameters[pair[0]].push(decodedValue);
				}
			} 
			return urlParameters;
		} catch (e) {
			//RSKYBOX.log.error(e, 'getUrlQueryString');
		}
	};

	r.decodeUrlComponent = function(component) {
		try {
			if(component) {
				return decodeURIComponent( component.replace(/\+/g, '%20') )
			} else {
				return component;
			}
		} catch (e) {
			//RSKYBOX.log.error(e, 'decodeUrlComponent');
		}
	};


	// status param: 'success', 'failure' or 'cancel'
	// httpErrorCode: HTTP error code
	// errorCode: application error code
	// NOTE: only one of the two error codes will be non-null on failure
	r.returnToIos = function(status, httpErrorCode, errorCode) {
		try {
		
			
			$('#addLoadPage').hide();
			$('#confirmPaymentPage').hide();
			$('#addCardPage').hide();
			$('#howMuchPage').hide();
	
	
			if(status != 'success' && status != 'failure' && status != 'cancel') {
				//RSKYBOX.log.error('returnToIos bad status', 'returnToIos');
				status = 'failure';
			}

			var returnUrl = "myDono://" + status;
			
			if(status === 'failure') {
			
				
				if(errorCode) {
					r.displayErrorMessage(errorCode);
				} else {
					alert("Error Processing Donation - There was an error processing your donation, please try again.");
				}
				
				
				//failure, show confirmation page and display error
				$('#confirmPaymentPage').show();

			}else{
				//success, going back to iOS
				 $('#donePayment').show();
		   		 $('div.finalMessage').text("Your Dono web session has ended, please close this tab return to the app to proceed.  Refreshing this page may cause duplicate transactions.");
		   			
		   		 window.location = returnUrl;

			}
           
          
           
           
         
		} catch (e) {
			//RSKYBOX.log.error(e, 'returnToIos');
		}
	};

	r.displayErrorMessage = function(errorCode){
	
			console.log("confirmPayment Error Code = -" + errorCode + "-");

				if(errorCode == 608) {
                    
                    alert("Invalid Credit Card - Your credit card could not be authorized.  Please double check your card information and try again.");
                    
                    
                } else if(errorCode == 605) {
                    
                     alert("Invalid Credit Card - Your credit card could not be authorized.  Please double check your card information and try again.");

                } else if (errorCode == 606){
                    
                     alert("Invalid Credit Card - Your credit card could not be authorized.  Please double check your card information and try again.");

                }else if(errorCode == 607) {
                
                    
                    alert("Invalid Credit Card - The number you entered for this credit card is inavlid.  Please double check your card information and try again.");

                } else if(errorCode == 400) {
                    alert("Error - Dono does not accept credit/debit card");
                } else if(errorCode == 401) {
                    alert("Over payment. Please check invoice and try again.");
                } else if(errorCode == 402) {
                    alert("Invalid amount. Please re-enter donation and try again.");
                } else if(errorCode == 610) {
                    
                    alert("Invalid Expiration Date - The expiration date you entered for this credit card is inavlid.  Please double check your card information and try again.");
                    
                    
                }  else if (errorCode == 699){
                    alert("Donation failed, please try again.");
                }else if (errorCode == 602){
                    alert("This donation may have already processed.  To be sure, please wait 30 seconds and then try again.");
                   
                }else if(errorCode == 612){
                    alert("This donation may have already processed.  To be sure, please wait 30 seconds and then try again.");
                    
                }else if (errorCode == 631){
                    alert("Invalid Authorization, please try again.");
                }else if (errorCode == 640){
                    alert("This donation may have already processed.  To be sure, please wait 30 seconds and then try again.");

                }else if (errorCode == 626){
                    alert("Invalid Security PIN - The CVV you entered for this credit card is inavlid.  Please double check your card information and try again.");
                   
                }else {
                    alert("Donation Failed - We were unable to process your donation at this time, please verify your internet connection and try again.");
                }
                
                
                
                
                
	};
	
	
	r.buildItems = function() {
		try {
			var items = [];
			var amounts = r.urlParameters['Amount'];
			var percents = r.urlParameters['Percent'];
			var itemIds = r.urlParameters['ItemId'];
			var values = r.urlParameters['Value'];
			var descriptions = r.urlParameters['Description'];

			if (typeof amounts === "string") {
				// amounts is a string
				items[0] = {"Amount": amounts, "Percent": percents, "ItemId": itemIds, "Value": values, "Description": descriptions};
			} else {
				// amounts is an array
				for(var i=0; i<amounts.length; i++) {
					items[i] = {"Amount": amounts[i], "Percent": percents[i], "ItemId": itemIds[i], "Value": values[i], "Description": descriptions[i]};
				}
			}

			return items;
		} catch (e) {
			//RSKYBOX.log.error(e, 'buildItems');
		}
	};
	
	
	r.buildCards = function() {
		try {
			var cards = [];
			var numbers = r.urlParameters['CardNumber'];
			var expirations = r.urlParameters['CardExpiration'];
			var types = r.urlParameters['CardType'];
			var tokens = r.urlParameters['CardToken'];

			if (typeof numbers === "string") {
				// amounts is a string
				cards[0] = {"Number": numbers, "Expiration": expirations, "Type": types, "Token": tokens};
			} else {
				// amounts is an array
				for(var i=0; i<numbers.length; i++) {
					cards[i] = {"Number": numbers[i], "Expiration": expirations[i], "Type": types[i], "Token": tokens[i]};
				}
			}

			return cards;
		} catch (e) {
		
			return [];
			//RSKYBOX.log.error(e, 'buildItems');
			//alert("error in build cards" + e);
		}
	};
	
	
	

	r.maskCcNumber = function(ccNumber) {
		try {
			var maskedCcNumber = ccNumber;
			if(ccNumber && ccNumber.length > 3) {
				maskedCcNumber = ccNumber.substring(ccNumber.length - 4);
				maskedCcNumber = "****" + maskedCcNumber;
			}
			return maskedCcNumber;
		} catch (e) {
			//RSKYBOX.log.error(e, 'maskCcNumber');
		}
	};

  return r;
}(ARC || {}, jQuery));

$(document).ready(function() {
	console.log("ready entered");
	//RSKYBOX.log.debug("document.ready entered ...");
	//var pathname = window.location.pathname;
	
	
	
	
	ARC.urlParameters = ARC.getUrlParameters();
	
	ARC.name = ARC.urlParameters['name'];
	ARC.serverUrl = ARC.urlParameters['serverUrl'];
	ARC.baseUrl = ARC.serverUrl;


	
	$('#donePayment').hide();

	$('div.name').text(ARC.name);


	// show AddCard page
	ARC.didComeFromPayment = "yes";
	$('#confirmPaymentPage').hide();
	$('#addCardPage').hide();
	$('#howMuchPage').show();



	var paramOne = ARC.urlParameters['quickOne'];
	var paramTwo = ARC.urlParameters['quickTwo'];
	var paramThree = ARC.urlParameters['quickThree'];
	var paramFour = ARC.urlParameters['quickFour'];




	$('#quickOne').text('$' + paramOne);
	$('#quickTwo').text('$' + paramTwo);
	$('#quickThree').text('$' + paramThree);
	$('#quickFour').text('$' + paramFour);

	



});

$(document).on('click', '.addCard', function(e){
	console.log("continue button on addCardPage clicked");

	window.scrollTo(0,0);
	e.preventDefault();
	
	
	ARC.ccNumber = $('#cardNumber').val();
	ARC.expirationDate = $('#expirationDate').val();
	ARC.ccv = $('#ccv').val();
	
	
	if (ARC.cardArray == null || ARC.cardArray.length == 0 || ARC.isNewCardDropdown.length > 0){
	
		if (ARC.ccNumber == null || ARC.ccNumber == "" || ARC.ccv == null || ARC.ccv == "" ||
			ARC.expirationDate == null || ARC.expirationDate == ""){
	
			alert("Please enter all payment information before continuing.");
			return;
		}	
	
	
		if (ARC.checkCardNumber(ARC.ccNumber)){
	
			ARC.urlParameters['cardType'] = ARC.getCardTypeFromNumber(ARC.ccNumber);
		
			// show the ConfirmPayment page
			$('#confirmPaymentPage').show();
			$('#addCardPage').hide();
			$('#donePayment').hide();


			// initialize ConfirmPage
		
			var maskedCcNumber = ARC.maskCcNumber(ARC.ccNumber);
			var card = ARC.urlParameters['cardType'] + " " + maskedCcNumber;
			$('div.card').text(card);
	
	
			var total = ARC.donationAmount;
		
			var convenienceFee = ARC.urlParameters['convenienceFee'];
			var convenienceFeeCap = ARC.urlParameters['convenienceFeeCap'];


			if (parseFloat(convenienceFee) > 0.0){
		
				if (parseFloat(ARC.donationAmount) < parseFloat(convenienceFeeCap)){
			
					total = parseFloat(ARC.donationAmount) + parseFloat(convenienceFee);
								
					ARC.chargedFee = convenienceFee;
				
					$('div.fee').text("* a processing fee of $" + parseFloat(Math.round(parseFloat(convenienceFee) * 100) / 100).toFixed(2) + 
					  " will be added to all amounts less than $" + parseFloat(Math.round(parseFloat(convenienceFeeCap) * 100) / 100).toFixed(2));

				}
			}
		
			total = parseFloat(Math.round(parseFloat(total) * 100) / 100).toFixed(2);
		
			$('div.total').text("$ " + total);
	
		}else{
			alert("Please enter a valid credit card number.");
		}
	
	
		$('#saveCard').show();

		ARC.saveCard = document.getElementById("saveCheck").checked = true;
	
		
	}else{
		$('#saveCard').hide();

		//used a selected Card
		
			var select = document.getElementsByTagName('select')[0];
			var index = select.selectedIndex;
			var card = ARC.cardArray[index];
			
			
			ARC.urlParameters['cardType'] = ARC.getCardTypeFromNumber(card["Number"]);
		
		
			ARC.ccNumber = "";
			ARC.expirationDate = "";
			ARC.ccv = "";
			ARC.ccToken = card["Token"];
			
			
			// show the ConfirmPayment page
			$('#confirmPaymentPage').show();
			$('#addCardPage').hide();
			$('#donePayment').hide();


			// initialize ConfirmPage
		
			var maskedCcNumber = ARC.maskCcNumber(card["Number"]);
			
			var card = ARC.urlParameters['cardType'] + " " + maskedCcNumber;
			$('div.card').text(card);
	
	
			var total = ARC.donationAmount;
		
			var convenienceFee = ARC.urlParameters['convenienceFee'];
			var convenienceFeeCap = ARC.urlParameters['convenienceFeeCap'];


			if (parseFloat(convenienceFee) > 0.0){
		
				if (parseFloat(ARC.donationAmount) < parseFloat(convenienceFeeCap)){
			
					total = parseFloat(ARC.donationAmount) + parseFloat(convenienceFee);
								
					ARC.chargedFee = convenienceFee;
				
					$('div.fee').text("* a processing fee of $" + parseFloat(Math.round(parseFloat(convenienceFee) * 100) / 100).toFixed(2) + 
					  " will be added to all amounts less than $" + parseFloat(Math.round(parseFloat(convenienceFeeCap) * 100) / 100).toFixed(2));

				}
			}
		
			total = parseFloat(Math.round(parseFloat(total) * 100) / 100).toFixed(2);
		
			$('div.total').text("$ " + total);
	
	}

	
		

	
	
	


	
});



$(document).on('click', '.addAmount', function(e){
	console.log("continue button on addCardPage clicked");


	
	
	window.scrollTo(0,0);
	e.preventDefault();
	ARC.donationAmount = $('#amount').val();
	
	var r = /^\$?[0-9]+(\.[0-9][0-9])?$/;
	
	
	if (r.test(ARC.donationAmount)){
	
		
		$('#confirmPaymentPage').hide();
		$('#addCardPage').show();
		$('#howMuchPage').hide();

	

		ARC.cardArray = ARC.buildCards();
		
		if (ARC.cardArray == null || ARC.cardArray.length == 0){
			
			//Show new card stuff
			
			$('#dropdown').hide();
			$('#cardInfo').show();

		}else{
		
			$('#dropdown').show();
			$('#cardInfo').hide();

		

			var select = document.getElementsByTagName('select')[0];
			select.options.length = 0; // clear out existing items
			for(var i=0; i < ARC.cardArray.length; i++) {
  				  
  				var card = ARC.cardArray[i];
				var displayString = card["Type"] + '  ****' + card["Number"].slice(-4) ;
								
				
    		  	select.options.add(new Option(displayString, i))
			}
		
		    select.options.add(new Option("+ New Card", i))

		}

		
	
	
	
	
	}else{
	
		alert("Please enter a valid amount.");
		return;
	
	}
	
	
	
	


	
});




$(document).on('click', '.backone', function(e){
	console.log("back button clicked");
	e.preventDefault();
	ARC.returnToIos('cancel');
});

$(document).on('click', '.backtwo', function(e){
	console.log("back button clicked");
	e.preventDefault();

	$('#confirmPaymentPage').hide();
	$('#addCardPage').hide();
	$('#howMuchPage').show();
			
});

$(document).on('click', '.backthree', function(e){
	console.log("back button clicked");
	e.preventDefault();

	$('#confirmPaymentPage').hide();
	$('#addCardPage').show();
	$('#howMuchPage').hide();
			
});



$(document).on('click', '.confirm', function(e){
	console.log("confirm button clicked");
	
	
	
	$('#addLoadPage').show();
	$('#confirmPaymentPage').hide();
	$('#addCardPage').hide();
	$('#howMuchPage').hide();

	ARC.saveCard = document.getElementById("saveCheck").checked;
                
	e.preventDefault();
	ARC.createPayment();
});




$(document).on('click', '.quickOne', function(e){


		var elem = document.getElementById("amount");
		elem.value = ARC.urlParameters['quickOne'] + '.00';
			
		$('#addAmount').click();

});

$(document).on('click', '.quickTwo', function(e){
		var elem = document.getElementById("amount");
		elem.value = ARC.urlParameters['quickTwo'] + '.00';
		
		$('#addAmount').click();

});


$(document).on('click', '.quickThree', function(e){
		var elem = document.getElementById("amount");
		elem.value = ARC.urlParameters['quickThree'] + '.00';
		
		$('#addAmount').click();

});


$(document).on('click', '.quickFour', function(e){
		var elem = document.getElementById("amount");
		elem.value = ARC.urlParameters['quickFour'] + '.00';
		
		$('#addAmount').click();

});

$(document).on('change', '.selecter', function(e){
	

	var select = document.getElementsByTagName('select')[0];
	var index = select.selectedIndex;
	
	if (index == ARC.cardArray.length){
		//new card
		
		$('#cardInfo').show();
	
		ARC.isNewCardDropdown = "yes";
		
	}else{
		
		$('#cardInfo').hide();
	
		ARC.isNewCardDropdown = "";
	}

});


// declare variables
var i = 0,
    before = [],
    after = [],
    value = [],
    number = '';

// reset all values
function resetVal() {
    i = 0;
    before = [];
    after = [];
    value = [];
    number = '';
    $("#amount").val("");
}

// add thousand separater
function addComma(num) {
  return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}



$(document).on('keyup', '.amount', function(e,v){

    if ((e.which >= 48) && (e.which <= 57)) {
        number = String.fromCharCode(e.which);
        $(this).val("");
        value.push(number);
        before.push(value[i]);
        if (i > 1) {
            after.push(value[i - 2]);
            before.splice(0, 1);
        }
        var val_final = after.join("") + "." + before.join("");
        $(this).val(addComma(val_final));
        i++;
        $(".amount").html(" " + $(this).val());
    } else {
        resetVal();
    }
});

