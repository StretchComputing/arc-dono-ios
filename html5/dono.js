var ARC = (function (r, $) {
  'use strict';

	r.createPaymentApiCodes = {
		106: "Username and/or Password incorrect, please try again"
	};

	r.confirmPaymentApiCodes = {
		106: "Username and/or Password incorrect, please try again"
	};

	r.urlParameters = [];

	r.createPayment = function() {
		var cpUrl = baseUrl + 'payments/create';
		r.urlParameters = r.getUrlParameters();
		var jsonData = {
			"AppInfo": {"App": "DONO", "OS":"IOS", “Version”:”1.0"},
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
			"Items": r.buildItems(),
		};

		try {
			$.ajax({
				dataType: 'json',
				contentType: 'application/json',
				type: 'POST',
				url: cpUrl,
				data: JSON.stringify(jsonData),
				//error: r.createPaymentError,
				success: r.createPaymentSuccess,
				statusCode: r.statusCodeHandlers(r.createPaymentApiError)
			});
		} catch (e) {
			RSKYBOX.log.error(e, 'createPayment');
		}
	};

	r.createPaymentSuccess = function(jqXHR) {
		try {
			// TODO
		} catch (e) {
			RSKYBOX.log.error(e, 'createPaymentSuccess');
		}
	};

	// no "try again" scenario errors so always just return error to iOS app
	r.createPaymentApiError = function(jqXHR) {
		try {
			var code = r.getApiStatus(jqXHR.responseText);
			RSKYBOX.log.info(code, 'createPaymentApiError');
			r.returnToIos('fail', code);
		} catch (e) {
			RSKYBOX.log.error(e, 'createPaymentApiError');
		}
	};

	// schedule: 3, 3, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10
	r.confirmPayment = function() {
		var cpUrl = baseUrl + 'payments/confirm';
		var jsonData = {};

		try {
			$.ajax({
				dataType: 'json',
				contentType: 'application/json',
				type: 'POST',
				url: cpUrl,
				data: JSON.stringify(jsonData),
				//error: r.confirmPaymentError,
				success: r.confirmPaymentSuccess,
				statusCode: r.statusCodeHandlers(r.confirmPaymentApiError)
			});
		} catch (e) {
			RSKYBOX.log.error(e, 'confirmPayment');
		}
	};

	r.confirmPaymentSuccess = function(jqXHR) {
		try {
			// TODO
		} catch (e) {
			RSKYBOX.log.error(e, 'confirmPaymentSuccess');
		}
	};

	// no "try again" scenario errors so always just return error to iOS app
	r.confirmPaymentApiError = function(jqXHR) {
		try {
			var code = r.getApiStatus(jqXHR.responseText);
			RSKYBOX.log.info(code, 'confirmPaymentApiError');
			r.returnToIos('fail', code);
		} catch (e) {
			RSKYBOX.log.error(e, 'confirmPaymentApiError');
		}
	};

	r.getUrlParameters = function() {
		try {
			var urlParameters = {};
			var query = window.location.search.substring(1);
			var params = query.split("&");
			for (var i=0;i<params.length;i++) {
				var pair = params[i].split("=");
				// If first entry with this name
				if (typeof urlParameters[pair[0]] === "undefined") {
					urlParameters[pair[0]] = pair[1];
					// If second entry with this name
				} else if (typeof urlParameters[pair[0]] === "string") {
					var arr = [ urlParameters[pair[0]], pair[1] ];
					urlParameters[pair[0]] = arr;
					// If third or later entry with this name
				} else {
					urlParameters[pair[0]].push(pair[1]);
				}
			} 
			return urlParameters;
		} catch (e) {
			RSKYBOX.log.error(e, 'getUrlQueryString');
		}
	};

	// status param: 'success' or 'fail'
	// code param: error code if status is 'fail'
	r.returnToIos = function(status, code) {
		try {

			// TODO .............

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

  return r;
}(ARC || {}, jQuery));
