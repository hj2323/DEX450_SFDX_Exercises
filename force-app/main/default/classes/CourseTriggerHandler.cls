public with sharing class CourseTriggerHandler {

    static final String RETIRED = 'Retired';
    static final String ENROLLED = 'Enrolled';
    static final String SCHEDULED = 'Scheduled';
    static final String CANCELLED = 'Cancelled';
    static final String ERROR_MESSAGE = 'Course has enrolled students';

    public static void checkStatus(List<Course__c> triggerNew, 
									Map<Id, Course__c> oldMap, 
									Map<Id, Course__c> newMap)  {
        /**
        *  If a Course Status is changed to retired, then we need to
        *  check to see if there are any Course Delivery records marked
        *  as Scheduled and if there is at least one attendee marked
        *  as Enrolled, then the change to retired should not happen
        *  and an error passed back
        */

        // Initialize a Set of Id's named courseIds
        Set<Id> courseIds = New Set<Id>();

        // Loop through all Course Delivery records to look for attendees
        for ( Course__c course :  triggerNew) {
            if ( oldMap.get(course.Id).Status__c != RETIRED && course.Status__c == RETIRED ) {

                // Add the course Id to the set named courseIds
                courseIds.add(course.Id);
            }
        }

        // Checks to see that we have records to process
        if ( courseIds.size() > 0 ) {

            // TODO #1: Declare a variable whose type is a Map where the key
			//	field is of type Id and the value field is of type Course_Delivery__c
            //  named courseDeliveryUpdate and initialize it to a newly constructed Map.

            Map<Id, Course_Delivery__c> courseDeliveryUpdate = new Map<Id, Course_Delivery__c>();
            for (List<Course_Delivery__c> cds : [SELECT Id, Course__c, Status__c,
                                                    (SELECT Status__c FROM Course_Attendees__r
                                                      WHERE Status__c = :ENROLLED)
                                                   FROM Course_Delivery__c
                                                  WHERE Course__c IN :courseIds AND Status__c = :SCHEDULED]) {

                for ( Course_Delivery__c cd : cds) {
                    if ( cd.Course_Attendees__r != null  && cd.Course_Attendees__r.size() > 0 ) {
                        newMap.get(cd.Course__c).addError(ERROR_MESSAGE);
                    } else {
                        // Change the status of the Course Delivery record to 'Cancelled'
                        cd.Status__c = CANCELLED;
                        // TODO #2: Using the Id field of the variable cd as the key
                        //          put the Course_Delivery__c sObject cd into the courseDeliveryUpdate map
                        courseDeliveryUpdate.put(cd.Id, cd);
                    }
                }
            }

            // TODO #3: Create an if statement that determines if the size of the courseDeliveryUpdate
            //          variable is greater than zero
            //          -- use the values method of the Map class to extract the Course_Delivery__c sObjects
            //             as the argument to the update statement
            // Update all Course Delivery records in single update
            if ( courseDeliveryUpdate.size() > 0 ) {
                update courseDeliveryUpdate.values();
            }


        }
    }
}
