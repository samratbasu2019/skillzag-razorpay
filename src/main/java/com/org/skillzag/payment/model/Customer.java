package com.org.skillzag.payment.model;

import lombok.Data;

@Data
public class Customer {
	
	private String customerName;
	private String email;
	private String phoneNumber;
	private String amount;

}
