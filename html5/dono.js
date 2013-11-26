var ARC = (function (r, $) {
  'use strict';

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

	r.createPayment = function() {
		try {
			RSKYBOX.log.debug("sending a createPayment to server");
			var cpUrl = baseUrl + 'payments/create';
			var appInfo = { "App": "DONO", "OS": "IOS", "Version": "1.0" };
			var jsonData = {
				"AppInfo": appInfo,
				"InvoiceAmount": r.urlParameters['invoiceAmount'],
				"Amount": r.urlParameters['amount'],
				"CustomerId": r.urlParameters['customerId'],
				"AuthenticationToken": r.urlParameters['authenticationToken'],
				"InvoiceId": r.urlParameters['invoiceId'],
				"MerchantId": r.urlParameters['merchantId'],
				"Gratuity": r.urlParameters['gratuity'],
				"Type": r.urlParameters['type'],
				"CardType": r.urlParameters['cardType'],
				"FundSourceAccount": r.urlParameters['fundSourceAccount'],
				"Expiration": r.urlParameters['expiration'],
				"Pin": r.urlParameters['pin'],
				"Anonymous": r.urlParameters['anonymous'],
				"Items": r.buildItems()
			};
			RSKYBOX.log.debug("createPayment jsonData = " + JSON.stringify(jsonData));
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
			RSKYBOX.log.error(e, 'createPayment');
		}
	};

	r.createPaymentSuccess = function(data, status, jqXHR) {
		try {
			RSKYBOX.log.debug("createPaymentSuccess entered, Success = " + data.Success);
			if(data.Success) {
				r.ticketId = data.Results;
				r.confirmPayment();
			} else {
				RSKYBOX.log.debug("createPaymentSuccess failed with error code = " + data.ErrorCodes[i].Code);
				r.returnToIos('failure', data.ErrorCodes[i].Code);
			}
		} catch (e) {
			RSKYBOX.log.error(e, 'createPaymentSuccess');
		}
	};

	// no "try again" scenario errors so always just return error to iOS app
	r.createPaymentApiError = function(jqXHR) {
		try {
			RSKYBOX.log.debug("createPaymentApiError entered");
			var code = r.getApiStatus(jqXHR.responseText);
			RSKYBOX.log.info(code, 'createPaymentApiError');
			r.returnToIos('failure', code);
		} catch (e) {
			RSKYBOX.log.error(e, 'createPaymentApiError');
		}
	};

	r.scheduleConfirmPayment = function(){
		RSKYBOX.log.debug("scheduling confirm with index = " + confirmIntervalIndex + " for " + r.confirmInterval[r.confirmIntervalIndex] + " ms");
		setTimeout(
			function(){
				r.confirmPayment();
			}, r.confirmInterval[r.confirmIntervalIndex]);
	};

	r.confirmPayment = function() {
		try {
			RSKYBOX.log.debug("sending a confirmPayment to server");
			var cpUrl = baseUrl + 'payments/confirm';
			var appInfo = { "App": "DONO", "OS": "IOS", "Version": "1.0" };
			var jsonData = {
				"AppInfo": appInfo,
				"TicketId": r.ticketId
			};
			RSKYBOX.log.debug("confirmPayment jsonData = " + JSON.stringify(jsonData));

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
			RSKYBOX.log.error(e, 'confirmPayment');
		}
	};

	r.confirmPaymentSuccess = function(data, status, jqXHR) {
		try {
			RSKYBOX.log.debug("confirmPaymentSuccess entered, Success = " + data.Success);

			if(data.Success) {
				// if anything in the Results field, that payment is complete
				if(data.Results) {
					RSKYBOX.log.debug("confirmPaymentSuccess payment is now complete");
					r.returnToIos('success', data.Results.PaymentId);
				} else {
					RSKYBOX.log.debug("confirmPaymentSuccess payment is not yet complete, scheduling another confirmation to be sent");
					r.confirmIntervalIndex++;
					if(r.confirmIntervalIndex < r.confirmInterval.length) {
						r.scheduleConfirmPayment();
					} else {
						RSKYBOX.log.debug("confirmPaymentSuccess failed be maximum number of confirms have been sent to server");
						r.returnToIos('failure', 'confirms timedout');
					}
				}
			} else {
				RSKYBOX.log.debug("confirmPaymentSuccess failed with error code = " + data.ErrorCodes[i].Code);
				r.returnToIos('failure', data.ErrorCodes[i].Code);
			}
		} catch (e) {
			RSKYBOX.log.error(e, 'confirmPaymentSuccess');
		}
	};

	// no "try again" scenario errors so always just return error to iOS app
	r.confirmPaymentApiError = function(jqXHR) {
		try {
			RSKYBOX.log.debug("confirmPaymentApiError entered");
			var code = r.getApiStatus(jqXHR.responseText);
			RSKYBOX.log.info(code, 'confirmPaymentApiError');
			r.returnToIos('failure', code);
		} catch (e) {
			RSKYBOX.log.error(e, 'confirmPaymentApiError');
		}
	};

	r.getUrlParameters = function() {
		try {
			RSKYBOX.log.debug("getUrlParameters entered");
			var urlParameters = {};
			var query = window.location.search.substring(1);
			var params = query.split("&");
			for (var i=0;i<params.length;i++) {
				var pair = params[i].split("=");
				var decodedValue = r.decodeUrlComponent(pair[1]);
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
			RSKYBOX.log.error(e, 'getUrlQueryString');
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
			RSKYBOX.log.error(e, 'decodeUrlComponent');
		}
	};


	// status param: 'success', 'failure' or 'cancel'
	// code param: error code or error message if status is 'failure' -- not currently used
	r.returnToIos = function(status, code) {
		try {
			if(status != 'success' && status != 'failure' && status != 'cancel') {
				RSKYBOX.log.error('returnToIos bad status', 'returnToIos');
				status = 'failure';
			}
			window.location = "myDono://" + status;
		} catch (e) {
			RSKYBOX.log.error(e, 'returnToIos');
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

			for(var i=0; i<Amounts.length; i++) {
				items[i] = {"Amount": amounts[i], "Percent": percents[i], "ItemId": itemIds[i], "Value": values[i], "Description": descriptions[i]};
			}
			return items;
		} catch (e) {
			RSKYBOX.log.error(e, 'buildItems');
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
			RSKYBOX.log.error(e, 'maskCcNumber');
		}
	};

  return r;
}(ARC || {}, jQuery));

$(document).ready(function() {
	RSKYBOX.log.debug("document.ready entered ...");
	var pathname = window.location.pathname;
	ARC.urlParameters = ARC.getUrlParameters();

	// set the amount and credit card details on the page using values extracted from URL params
	var total = "$" + ARC.urlParameters['invoiceAmount'];
	$('div.total').text(total);
	var ccNumber = ARC.urlParameters['fundSourceAccount'];
	ccNumber = ARC.maskCcNumber(ccNumber);
	var card = ARC.urlParameters['cardType'] + " " + ccNumber;
	$('div.card').text(card);
});

$(document).on('click', '.back', function(e){
	e.preventDefault();
	ARC.returnToIos('cancel');
});

$(document).on('click', '.confirm', function(e){
	e.preventDefault();
	ARC.createPayment();
});



