trigger CourseDeliveryTrigger on Course_Delivery__c (before insert, 
                                                     before update) {
    // TODO #1: Invoke the static method of the 
    //   CourseDeliveryTriggerHandler class called 
    //   preventInvalidCourseDeliveries and pass in the Trigger.new 
	//   and Trigger.oldMap variables.
    CourseDeliveryTriggerHandler.preventInvalidCourseDeliveries(Trigger.new,Trigger.oldMap);
                         
}
