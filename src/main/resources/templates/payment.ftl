<html>

<head>

    <!-- added for razorpay -->
    <meta name="viewport" content="width=device-width">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css"
          integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">


</head>

<body class="nav-md">
<div class="container body">
    <div class="main_container">

        <nav class="navbar navbar-light bg-light" style="background-color: #ffffff!important;">
            <a class="navbar-brand"></a>
        </nav>

        <div class="alert alert-success" id="pay-success" style="display:none;">
            <strong>Payment Completed Successfully</strong>
        </div>

        <form id="msform">

            <div class="form-group">
                <p>Subscription ID:
                <#if subscriptionID?has_content>
                     ${subscriptionID}
                </#if>
                </p>
            </div>

            <div class="form-group">
                <p>Course Name:
                <#if courseName?has_content>
                    ${courseName}
                 </#if>
                </p>
            </div>

            <div class="form-group">
                            <p>Payment will be made for the user-id:
                            <#if userID?has_content>
                                ${userID}
                             </#if>
                            </p>
             </div>

            <div class="form-group">
                <label for="email">Name</label>
                <input type="text" class="form-control" id="customerName" name="customerName"
                       placeholder="Enter Customer Name" required="required">
            </div>

            <div class="form-group">
                <label for="email">Email address</label>
                <input type="email" class="form-control" id="email" name="email" placeholder="Enter Email"
                       required="required">
            </div>

            <div class="form-group">
                <label for="phoneNo">Phone No</label>
                <input type="text" class="form-control" id="phoneNo" name="phoneNo" placeholder="Phone No">
            </div>

            <div class="form-group">
                <label for="amount">Amount</label>
                <input type="text" class="form-control" id="amount" name="amount" placeholder="Amount"
                       required="required">
            </div>

            <button type="button" class="btn btn-primary" id="rzp-button1" style="margin-top:-2px">Pay</button>
        </form>


    </div>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"
        integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q"
        crossorigin="anonymous"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"
        integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl"
        crossorigin="anonymous"></script>
<!-- razorpay -->
<script src="https://checkout.razorpay.com/v1/checkout.js"></script>

<script type="text/javascript">
		
		function doPost(path, requestObject, isAsync) {
			var resp;
				$.ajax({
		            url: path,
		            type: 'POST',
		            data: requestObject,
		            contentType: "application/json; charset=UTF-8",
		            async: isAsync,
		            success: function (data) {	
		            	resp = JSON.parse(data)
		            }
		       })
		       return resp;
			}
		
		


</script>

<script>
	var resp = null;
	
	/**
		Manual Checkout for Razor Pay
	**/
	
	var options = {
		    "key": "",
		    "amount": "", 
		    "name": "",
		    "description": "",
		    "image": "",
		    "order_id":"",
		    "handler": function (response){
		    	alert(response.razorpay_payment_id); /* use this razorpay_payment_id for feature reference to this order */
		    	$('#msform')[0].reset();
		    	$('#pay-success').show();
		    	
		    },
		    "prefill": {
		        "name": "",
		        "email": ""
		    },
		    "notes": {
		        "address": ""
		    },
		    "theme": {
		        "color": ""
		    }
		};
		

		document.getElementById('rzp-button1').onclick = function(e){
			
			
			var reqObject = $('#msform').serializeArray();
			var indexedReqObj = {};
			$.map(reqObject, function(n, i){
				indexedReqObj[n['name']] = n['value'];
			});
			
			resp = doPost("/skillzag-payment/createPayment", JSON.stringify(indexedReqObj), false);
			if(resp.statusCode == 200) {
				options.key = resp.razorPay.secretKey;
				options.order_id = resp.razorPay.razorpayOrderId;
				options.amount = resp.razorPay.applicationFee; //paise
				options.name = resp.razorPay.merchantName;
				options.description = resp.razorPay.purchaseDescription;
				options.image = resp.razorPay.imageURL;
				options.prefill.name = resp.razorPay.customerName;
				options.prefill.email = resp.razorPay.customerEmail;
				options.notes.address = resp.razorPay.notes;
				options.theme.color = resp.razorPay.theme;
				var rzp1 = new Razorpay(options);
				rzp1.open();
				e.preventDefault();
			} else {
				//do something else
			}
		}
	


</script>


</body>


</html>