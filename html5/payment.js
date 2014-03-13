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
	r.multipleItems = [];
	r.selectedItems = [];

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
	
	r.deleteCard = function(cardIndex) {
		try {
		

			//RSKYBOX.log.debug("sending a createPayment to server");
			console.log("sending delete card to server");
			var cpUrl = r.baseUrl + 'customers/creditcards/delete/' + ARC.cardArray[cardIndex]["CCToken"];
			var appInfo = { "App": "DONO", "OS": "IOS", "Version": "1.0" };

			console.log("URL = " + cpUrl);

	
			var jsonData = {
				"AppInfo": appInfo,
		

			};
			//RSKYBOX.log.debug("createPayment jsonData = " + JSON.stringify(jsonData));
			//console.log("addCard jsonData = " + JSON.stringify(jsonData));
			r.confirmIntervalIndex = 0;

			$.ajax({
				dataType: 'json',
				contentType: 'application/json',
				type: 'DELETE',
				url: cpUrl,
				data: JSON.stringify(jsonData),
				headers: {'Authorization' : r.urlParameters['token']},
				//error: r.createPaymentError,
				success: r.deleteCardSuccess,
				statusCode: r.statusCodeHandlers(r.deleteCardError)
			});
		} catch (e) {
			
			alert("Error deleting your card, please try again.");

			//RSKYBOX.log.error(e, 'createPayment');
		}
	};

	r.deleteCardSuccess = function(data, status, jqXHR) {
		try {
		
			//RSKYBOX.log.debug("createPaymentSuccess entered, Success = " + data.Success);
			console.log("Delete Response: " + JSON.stringify(data));
			
			r.CardArray = [];
			if(data.Success) {
							
				alert("Your card was deleted successfully!");

				$('#deleteCardLoading').hide();
				$('#addLoadPage').show();
	
				ARC.getCardList();
				
			} else {
				alert("Failed to delete card, please try again.");
				$('#deleteCardLoading').hide();

				$('#cardsPage').show();
				//RSKYBOX.log.debug("createPaymentSuccess failed with error code = " + data.ErrorCodes[i].Code);
			}
		} catch (e) {
			//alert("Exception " + e);
			//RSKYBOX.log.error(e, 'createPaymentSuccess');
		}
	};

	// no "try again" scenario errors so always just return error to iOS app
	r.deleteCardError = function(jqXHR) {
		try {
			alert("Failed to delete card, please try again.");
			$('#deleteCardLoading').hide();

			$('#cardsPage').show();
		} catch (e) {
			//RSKYBOX.log.error(e, 'createPaymentApiError');
		}
	};
	
	
	
	
	
	r.addCreditCard = function() {
		try {
		

			//RSKYBOX.log.debug("sending a createPayment to server");
			console.log("sending add card to server");
			var cpUrl = r.baseUrl + 'customers/creditcards/create';
			var appInfo = { "App": "DONO", "OS": "IOS", "Version": "1.0" };

	
	
			try{
				ARC.ccNumber = ARC.ccNumber.replace(/\s+/g, '');
				ARC.expirationDate = ARC.expirationDate.replace(/\s+/g, '');

			}catch (e){
			
			}
	
			var jsonData = {
				"AppInfo": appInfo,
				"Number": ARC.ccNumber,
				"ExpirationDate": ARC.expirationDate,
				"CVV": ARC.ccv,


			};
			//RSKYBOX.log.debug("createPayment jsonData = " + JSON.stringify(jsonData));
			//console.log("addCard jsonData = " + JSON.stringify(jsonData));
			r.confirmIntervalIndex = 0;

			$.ajax({
				dataType: 'json',
				contentType: 'application/json',
				type: 'POST',
				url: cpUrl,
				data: JSON.stringify(jsonData),
				headers: {'Authorization' : r.urlParameters['token']},
				//error: r.createPaymentError,
				success: r.addCardSuccess,
				statusCode: r.statusCodeHandlers(r.addCardError)
			});
		} catch (e) {
			
			alert("Error adding your card, please try again.");

			//RSKYBOX.log.error(e, 'createPayment');
		}
	};

	r.addCardSuccess = function(data, status, jqXHR) {
		try {
		
			//RSKYBOX.log.debug("createPaymentSuccess entered, Success = " + data.Success);
			console.log("Add Response: " + JSON.stringify(data));
			
			r.CardArray = [];
			if(data.Success) {
							
				alert("Your card was added successfully!");

				$('#addCardLoading').hide();
				$('#addLoadPage').show();
	
				ARC.getCardList();
				
			} else {
				alert("Failed to add card, please try again.");
				$('#addCardPage').show();
				$('#addCardLoading').hide();
				//RSKYBOX.log.debug("createPaymentSuccess failed with error code = " + data.ErrorCodes[i].Code);
			}
		} catch (e) {
			//alert("Exception " + e);
			//RSKYBOX.log.error(e, 'createPaymentSuccess');
		}
	};

	// no "try again" scenario errors so always just return error to iOS app
	r.addCardError = function(jqXHR) {
		try {
			alert("Failed to add card, please try again.");
			$('#addCardPage').show();
			$('#addCardLoading').hide();
		} catch (e) {
			//RSKYBOX.log.error(e, 'createPaymentApiError');
		}
	};
	
	
	
	


	r.getCardList = function() {
		try {
		

			//RSKYBOX.log.debug("sending a createPayment to server");
			console.log("sending get card list to server");
			var cpUrl = r.baseUrl + 'customers/creditcards/list';
			var appInfo = { "App": "DONO", "OS": "IOS", "Version": "1.0" };

			console.log("URL: " + cpUrl);
			console.log("Auth: " + r.urlParameters['token']);
			
			var jsonData = {
				"AppInfo": appInfo,
				"UserId": r.urlParameters['customerId'],
				
			};
			//RSKYBOX.log.debug("createPayment jsonData = " + JSON.stringify(jsonData));
			console.log("getCards jsonData = " + JSON.stringify(jsonData));
			r.confirmIntervalIndex = 0;

			$.ajax({
				dataType: 'json',
				contentType: 'application/json',
				type: 'SEARCH',
				url: cpUrl,
				data: JSON.stringify(jsonData),
				headers: {'Authorization' : r.urlParameters['token']},
				//error: r.createPaymentError,
				success: r.getCardListSuccess,
				statusCode: r.statusCodeHandlers(r.getCardListAPIError)
			});
		} catch (e) {
					alert("Error getting payment info, please try again.");

			//RSKYBOX.log.error(e, 'createPayment');
		}
	};

	r.getCardListSuccess = function(data, status, jqXHR) {
		try {
		
			//RSKYBOX.log.debug("createPaymentSuccess entered, Success = " + data.Success);
			console.log("Response: " + JSON.stringify(data));
			
			r.CardArray = [];
			if(data.Success) {
			
				if (data.Results){
								
					r.cardArray = data.Results;

				}else{
					

				}
				
				doneWithGetCards();

				
			} else {
				alert("Failed to load card list, please try again.");

				//RSKYBOX.log.debug("createPaymentSuccess failed with error code = " + data.ErrorCodes[i].Code);
			}
		} catch (e) {
			//alert("Exception " + e);
			//RSKYBOX.log.error(e, 'createPaymentSuccess');
		}
	};

	// no "try again" scenario errors so always just return error to iOS app
	r.getCardListAPIError = function(jqXHR) {
		try {
			alert("Failed to load card list, please try again.");
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
		

			var returnUrl = "myDono://" + status;
			
		   			
		   	window.location = returnUrl;

         
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
	
	r.buildFinalItems = function() {
		try {
			var items = [];
		
			for(var i=0; i < r.selectedItems.length; i++) {
			
				var amount = r.selectedItems[i]["TypeAmount"];
				
				if (amount.length > 0){
					var amountDouble = parseFloat(amount);
					
					if (amountDouble > 0.0){
						var percent = amountDouble/r.donationAmount;
								
						items[items.length] = {"ItemId": r.selectedItems[i]["TypeId"], "Amount": r.selectedItems[i]["TypeAmount"], "Percent":percent};
					}

				}
				
				

			
			}
		

			return items;
			
			
		} catch (e) {
			//RSKYBOX.log.error(e, 'buildItems');
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
	
	r.buildMultiple = function() {
		try {
			var items = [];
			var amounts = r.urlParameters['TypeDescription'];
			var percents = r.urlParameters['TypeId'];
			

			if (typeof amounts === "string") {
				// amounts is a string
				items[0] = {"TypeDescription": amounts, "TypeId": percents, "TypeSelected":"no", "TypeAmount":"0"};
			} else {
				// amounts is an array
				for(var i=0; i<amounts.length; i++) {
					items[i] = {"TypeDescription": amounts[i], "TypeId": percents[i], "TypeSelected":"no", "TypeAmount":"0"};
				}
			}

			return items;
		} catch (e) {
			//RSKYBOX.log.error(e, 'buildItems');
		}
	};
	
	
	r.buildSelectedItems = function() {
		try {
			var items = [];
		
			for(var i=0; i < r.multipleItems.length; i++) {
			
				if (r.multipleItems[i]["TypeSelected"] == "yes"){
				
					items[items.length] = {"TypeDescription": r.multipleItems[i]["TypeDescription"], "TypeId": r.multipleItems[i]["TypeId"], "TypeSelected":"yes", "TypeAmount":"0"};

				}
			}
		

			return items;
		} catch (e) {
			alert("ERROR: " + e);
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




function setUpTable() {
  
  var tablecontents = "";
   		tablecontents = "<table class='options'>";
   		for (var i = 0; i < ARC.multipleItems.length; i ++)
  		{
  		    tablecontents += "<tr class='clickRow' id='" + i + "'>";
   		    tablecontents += "<td class='column1'>" + ARC.multipleItems[i]["TypeDescription"] + "</td>";
   		    
   		    if (ARC.multipleItems[i]["TypeSelected"] == "yes"){
   		        		tablecontents += "<td class='column2'><img src='bluecheck.png' alt='back_img' height='30' width='30'></td>";

   		    }else{
   		        		tablecontents += "<td class='column2'></td>";

   		    }
    	    tablecontents += "</tr>";
  		}
  		
  		tablecontents += "</table>";
  		document.getElementById("tablespace").innerHTML = tablecontents;


		$(".clickRow").click(function() {
            
            var index = $(this).attr('id');
            
            if (ARC.multipleItems[index]["TypeSelected"] == "yes"){
            	
            	ARC.multipleItems[index]["TypeSelected"] = "no";
            }else{
            	ARC.multipleItems[index]["TypeSelected"] = "yes";

            }
            
            setUpTable();


            
      	});
      	
      	
      	
}

function doneWithGetCards(){
	
	$('#addCardPage').hide();
	$('#addLoadPage').hide();
	$('#cardsPage').show();
		
		
	if(ARC.cardArray.length > 0){
	
			$('#nocards').hide();
			$('#cardstable').show();

			setUpTableMultiple();

	}else{
			$('#cardstable').hide();
			$('#nocards').show();


	}
	
					
					
					
}
function setUpTableMultiple() {
  
  
  try{
  		var tablecontents = "";
   		tablecontents = "<table class='multiple'>";
   		   		
   		   		

		
		for (var i = 0; i < ARC.cardArray.length; i ++)
  		{
  		
  			var imageName = "generic.png";
  			var cardType = ARC.getCardTypeFromNumber(ARC.cardArray[i]["Number"]);
  			
  			if (cardType == "Visa"){
  				imageName = "visa.png";
  			}else if (cardType == "MasterCard"){
  				imageName = "mastercard.png";
  			}else if (cardType == "Amex"){
  				imageName = "amex.png";
  			}else if (cardType == "Discover"){
  				imageName = "discover.png";
  			}
  			
  		    tablecontents += "<tr class='multipleRow' id='" + i + "'>";
   		    tablecontents += "<td class='column1'><img src='" + imageName + "' alt='back_img' height='21' width='33' style='float:left; padding-top:10px;'><div class='colummultiplelabel'>" + ARC.cardArray[i]["Number"]; 
   		    
   		    tablecontents += "</div><div class='deleteImage' onclick='deleteClicked("+i+")'><img src='redx.png' alt='back_img' height='30' width='30'></div>";

   		    tablecontents += "</br>";

   		
   		    
   		    tablecontents += "</td>";
    	    tablecontents += "</tr>";
  		}
  		
  		tablecontents += "</table>";
  		document.getElementById("cardstable").innerHTML = tablecontents;

	}catch(e){
		alert("Exception: " + e);
	}
      	
      	
}


function deleteClicked(index) {
	deleteCardLoading
	
	$('#deleteCardLoading').show();
	$('#cardsPage').hide();

	ARC.deleteCard(index);
}






$(document).on('click', '.selectOptions', function(e){
			
		console.log("continue on select options clicked");

		var anySelected = false;
		
		for (var i = 0; i < ARC.multipleItems.length; i ++){
				
			if (ARC.multipleItems[i]["TypeSelected"] == "yes"){
				anySelected = true;
			}
		}
		
		if (anySelected == true){
			//go to selectmultiple page
					
			$('#selectOptions').hide();
			$('#howMuchMultiplePage').show();
			
			ARC.selectedItems = ARC.buildSelectedItems();
			
			setUpTableMultiple();

			
		}else{
			alert("Please select at least 1 donation area before continuing.");
		}

});


$(document).on('click', '.selectMultiple', function(e){
			
		try{
			console.log("continue on select multiple clicked");

			var totalAmount = 0.0;

			for (var i = 0; i < ARC.selectedItems.length; i ++)
  			{
  				var itemId = "amountmultiple" + i;
  				
  				var elemString = document.getElementById(itemId).value;
  				
  				if (elemString.length > 0){
  					var elemFloat = parseFloat(elemString);
  					totalAmount += elemFloat;
  					ARC.selectedItems[i]["TypeAmount"] = elemString;
  				}
  				
  				

  			}
		
			
			if (totalAmount > 0.0){
				
					
				window.scrollTo(0,0);
				ARC.donationAmount = totalAmount;
			
			
		
					if (ARC.donationAmount > 1.00){
						$('#howMuchMultiplePage').hide();
						$('#addCardPage').show();

	

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
						alert("Please enter an amount greater than $1.00");

					}

				
			}else{
				alert("Please choose an amount for at least one area.");
			}
		
			
		
		} catch (e) {
			//alert("Exception " + e);
			
		}
		

});





$(document).ready(function() {
	console.log("ready entered");
	//RSKYBOX.log.debug("document.ready entered ...");
	//var pathname = window.location.pathname;
	
	
	
	
	ARC.urlParameters = ARC.getUrlParameters();
	
	ARC.name = ARC.urlParameters['name'];
	ARC.serverUrl = ARC.urlParameters['serverUrl'];
	ARC.baseUrl = ARC.serverUrl;


	$('#addCardPage').hide();
	$('#addLoadPage').show();
	
	ARC.getCardList();

	



});

$(document).on('click', '.addNewCard', function(e){

			$('#addCardPage').show();
			$('#cardsPage').hide();


});

$(document).on('click', '.addCard', function(e){
	console.log("continue button on addCardPage clicked");

	window.scrollTo(0,0);
	e.preventDefault();
	
	
	ARC.ccNumber = $('#cardNumber').val();
	ARC.expirationDate = $('#expirationDate').val();
	ARC.ccv = $('#ccv').val();
	
	
		if (ARC.ccNumber == null || ARC.ccNumber == "" || ARC.ccv == null || ARC.ccv == "" ||
			ARC.expirationDate == null || ARC.expirationDate == ""){
	
			alert("Please enter all payment information before continuing.");
			return;
		}	
	
	
		if (ARC.checkCardNumber(ARC.ccNumber)){		

			//Add the card
			
			
			$('#addCardPage').hide();
			$('#addCardLoading').show();
			
			ARC.addCreditCard();

		}else{
			alert("Please enter a valid credit card number.");
		}

	
});








$(document).on('click', '.backcards', function(e){
	console.log("back button clicked");
	e.preventDefault();
	
	$('#addCardPage').hide();
	$('#cardsPage').show();
			
});


$(document).on('click', '.backios', function(e){
	console.log("back button clicked");
	e.preventDefault();
	ARC.returnToIos('cards');
});







