public class CourseDeliveryTriggerHandler {

    private static Set<Date> allHolidays = new Set<Date>();

    static {
        //Fetch the current holidays.
        //For simplicity's sake, we've assumed no recurring holidays
        for (List<Holiday> holidays : [SELECT ActivityDate FROM Holiday]) {
            for (Holiday h : holidays) {
                allHolidays.add(h.ActivityDate);
            }
        }
    }

    public static void preventInvalidCourseDeliveries(
                        List<Course_Delivery__c> newCourseDeliveryList,
                        Map<ID, Course_Delivery__c> oldCourseDeliveryMap) {
        for (Course_Delivery__c courseDelivery : newCourseDeliveryList) {
			Boolean checkDate = (trigger.isInsert || 
                oldCourseDeliveryMap.get(courseDelivery.Id).Start_Date__c
                                             != courseDelivery.Start_Date__c);
			if (checkDate && courseDelivery.Start_Date__c != NULL) {
                //Prevent the invoking DML action if the Start Date 
                //  is in the allHolidays set.
                if ( allHolidays.contains(courseDelivery.Start_Date__c) ) {
                    courseDelivery.Start_Date__c.addError(
                        'Course Delivery cannot be scheduled because it starts on a holiday.');
                    
                    // TODO #1
                    // Immediately Publish a platform event with details of the error
                    Error_Message__e event = new Error_Message__e();
                    event.Source_Component__c = 'CourseDeliveryTriggerHandler';
                    event.Error_Message__c = 'Course Delivery cannot be scheduled because it starts on a holiday.';
                    EventBus.publish(event);
                }
            }
        }
    }
}