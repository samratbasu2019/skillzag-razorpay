package com.org.skillzag.payment.controller;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.Map;

import org.json.JSONObject;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.*;

import com.google.gson.Gson;
import com.razorpay.Order;
import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;
import com.org.skillzag.payment.model.Customer;
import com.org.skillzag.payment.model.RazorPay;
import com.org.skillzag.payment.model.Response;
import org.springframework.web.servlet.ModelAndView;

/**
 * 
 * @author rahul
 * This can only be used for payment for order in RazorPay.
 */
@Controller
public class SkillZagResource {
	
	private RazorpayClient client;
	private static Gson gson = new Gson();

	private static final String SECRET_ID = "rzp_test_oDw757e5auoleh";
	private static final String SECRET_KEY = "Lpq6MdB30qJzz8tEHsinRGrJ";
	
	public SkillZagResource() throws RazorpayException {
		this.client =  new RazorpayClient(SECRET_ID, SECRET_KEY); 
	}
	
	@GetMapping(value="/")
	public String getHome() {
		return "redirect:/home";
	}
	@GetMapping(value="/home")
	public ModelAndView getHomeInit() {
		String viewName = "payment";
		ModelAndView modelAndView = new ModelAndView();
		modelAndView.addObject("subscriptionID" , "2132434fasdhs");
		modelAndView.addObject("courseName" , "Test Course");
		modelAndView.setViewName(viewName);
		return modelAndView;
	}
	
	@RequestMapping(value="/createPayment", method=RequestMethod.POST)
	@ResponseBody
	public ResponseEntity<String> createOrder(@RequestBody Customer customer) {

		try {
			/**
			 * creating an order in RazorPay.
			 * new order will have order id. you can get this order id by calling  order.get("id")
			 */
			Order order = createRazorPayOrder( customer.getAmount() );
			RazorPay razorPay = getRazorPay((String)order.get("id"), customer);
			
			return new ResponseEntity<String>(gson.toJson(getResponse(razorPay, 200)),
					HttpStatus.OK);
		} catch (RazorpayException e) {
			e.printStackTrace();
		}
		return new ResponseEntity<String>(gson.toJson(getResponse(new RazorPay(), 500)),
				HttpStatus.EXPECTATION_FAILED);
	}
	
	private Response getResponse(RazorPay razorPay, int statusCode) {
		Response response = new Response();
		response.setStatusCode(statusCode);
		response.setRazorPay(razorPay);
		return response;
	}	
	
	private RazorPay getRazorPay(String orderId, Customer customer) {
		RazorPay razorPay = new RazorPay();
		razorPay.setApplicationFee(convertRupeeToPaise(customer.getAmount()));
		razorPay.setCustomerName(customer.getCustomerName());
		razorPay.setCustomerEmail(customer.getEmail());
		razorPay.setMerchantName("SkillZag");
		razorPay.setPurchaseDescription("SkillZag Purchase");
		razorPay.setRazorpayOrderId(orderId);
		razorPay.setSecretKey(SECRET_ID);
		razorPay.setTheme("#F37254");
		razorPay.setNotes("notes"+orderId);
		
		return razorPay;
	}
	
	private Order createRazorPayOrder(String amount) throws RazorpayException {
		
		JSONObject options = new JSONObject();
		options.put("amount", convertRupeeToPaise(amount));
		options.put("currency", "INR");
		options.put("receipt", "txn_123456");
		options.put("payment_capture", 1); // You can enable this if you want to do Auto Capture. 
		return client.Orders.create(options);
	}
	
	private String convertRupeeToPaise(String paise) {
		BigDecimal b = new BigDecimal(paise);
		BigDecimal value = b.multiply(new BigDecimal("100"));
		return value.setScale(0, RoundingMode.UP).toString();
		 
	}
	

}
