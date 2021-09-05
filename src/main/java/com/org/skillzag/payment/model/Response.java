package com.org.skillzag.payment.model;

import lombok.Data;

/**
 * 
 * @author rahul
 *
 */
@Data
public class Response {
	private int statusCode;
	private RazorPay razorPay;

}
