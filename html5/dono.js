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
	r.confirmIntervalIndex = null;
	r.ticketId = null;
	r.ccNumber = null;
	r.expirationDate = null;
	r.ccv = null;

	r.createPayment = function() {
		try {
			//RSKYBOX.log.debug("sending a createPayment to server");
			console.log("sending a createPayment to server");
			var cpUrl = r.baseUrl + 'payments/create';
			var appInfo = { "App": "DONO", "OS": "IOS", "Version": "1.0" };
			var jsonData = {
				"AppInfo": appInfo,
				"InvoiceAmount": r.urlParameters['invoiceAmount'],
				"Amount": r.urlParameters['invoiceAmount'],
				"CustomerId": r.urlParameters['customerId'],
				"AuthenticationToken": r.urlParameters['authenticationToken'],
				"InvoiceId": r.urlParameters['invoiceId'],
				"MerchantId": r.urlParameters['merchantId'],
				"Gratuity": r.urlParameters['gratuity'],
				"Type": r.urlParameters['type'],
				"CardType": r.urlParameters['cardType'],
				"FundSourceAccount": ARC.ccNumber,
				"Expiration": ARC.expirationDate,
				"Pin": ARC.ccv,
				"Anonymous": r.urlParameters['anonymous'],
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
		console.log("scheduling confirm with index = " + confirmIntervalIndex + " for " + r.confirmInterval[r.confirmIntervalIndex] + " ms");
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
				if(data.Results) {
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
			if(status != 'success' && status != 'failure' && status != 'cancel') {
				//RSKYBOX.log.error('returnToIos bad status', 'returnToIos');
				status = 'failure';
			}

			var returnUrl = "myDono://" + status;
			if(status === 'failure') {
				if(httpErrorCode) {
					returnUrl = returnUrl + "?httpErrorCode=" + httpErrorCode;
				} else {
					returnUrl = returnUrl + "?errorCode=" + errorCode;
				}
			}
           
           
			window.location = returnUrl;
		} catch (e) {
			//RSKYBOX.log.error(e, 'returnToIos');
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
	ARC.serverUrl = ARC.urlParameters['serverUrl']
	ARC.baseUrl = ARC.serverUrl;

	// if a CC# was passed as a URL param, show the ConfirmPayment page, otherwise, show the add card page
	ARC.ccNumber = ARC.urlParameters['fundSourceAccount'];
	ARC.expirationDate = ARC.urlParameters['expiration'];
	ARC.ccv = ARC.urlParameters['pin'];
	if(ARC.ccNumber) {
		// show ConfirmPayment page
		$('#confirmPaymentPage').show();
		$('#addCardPage').hide();
	} else {
		// show AddCard page
		$('#confirmPaymentPage').hide();
		$('#addCardPage').show();
	}
});

$(document).on('click', '.addCard', function(e){
	console.log("continue button on addCardPage clicked");
	e.preventDefault();
	ARC.ccNumber = $('#cardNumber').val();
	ARC.expirationDate = $('#expirationDate').val();
	ARC.ccv = $('#ccv').val();

	// TODO -- add CC# validation

	// show the ConfirmPayment page
	$('#confirmPaymentPage').show();
	$('#addCardPage').hide();

	// initialize ConfirmPage
	var total = "$" + ARC.urlParameters['invoiceAmount'];
	$('div.total').text(total);
	var maskedCcNumber = ARC.maskCcNumber(ARC.ccNumber);
	var card = ARC.urlParameters['cardType'] + " " + maskedCcNumber;
	$('div.card').text(card);
});

$(document).on('click', '.back', function(e){
	console.log("back button clicked");
	e.preventDefault();
	ARC.returnToIos('cancel');
});

$(document).on('click', '.confirm', function(e){
	console.log("confirm button clicked");
	e.preventDefault();
	ARC.createPayment();
});



