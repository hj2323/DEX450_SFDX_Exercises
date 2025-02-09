public with sharing class SearchCourses_CC {

    /**
     *  This controller is used by both the SearchCoursesPage & ListCourseDeliveriesPage
     *  VF pages. Users will select courses using the checkboxes and then click
     *  to see the upcoming course deliveries for those courses.
     */

    // Represents the main course list
    public List<CourseWrapper> courseList {
        get {
            if (courseList == null) {
                courseList = new List<CourseWrapper>();
                for (Course__c course : [SELECT Name, Certification__r.Name, Duration__c, Status__c,
                                           (SELECT id FROM Course_Deliveries__r WHERE Status__c != 'Cancelled' 
										    and Start_Date__c >= TODAY)
                                         FROM Course__c]) {
                    courseList.add(new CourseWrapper(course));
                }
            }
            return courseList;
        }
        set;
    }

    // Contains only the course selected
    public Map<Id, CourseWrapper> selectedCourses {
        get {
            if (selectedCourses == null) {
                selectedCourses = new Map<Id, CourseWrapper>();
            }
            return selectedCourses;
        }
        private set;
    }

    // Action triggered from the "See Upcoming Course Deliveries" button
    public PageReference listDeliveries() {

        // First clear out any previously selected courses
        selectedCourses.clear();

        // Add the newly selected courses to the map
        for (CourseWrapper cw : courseList) {
            if (cw.checked) {
                selectedCourses.put(cw.course.Id, cw);
            }
        }

        /** TODO #1: Write an If-else statement that implements the following algorithm:
         *             -- If the size of the selectedCourses property is greater than 0
         *                -- return Page.ListCourseDeliveriesPage
         *             -- else:
         *                -- call the addMessage method of the ApexPages class passing in
         *                   a newly constructed instance of the ApexPages.message class.
         *                   The ApexPages.Message class constructor should be passed
         *                   two parameters:
         *                   -- the enumerated value ApexPages.Severity.ERROR
         *                   -- the String 'Please select at least one Course'
         *                   -- return null
         */
        if(selectedCourses.size() > 0 ){
            return Page.ListCourseDeliveriesPage;
        }else{
            ApexPages.addMessage(new
            ApexPages.message(ApexPages.Severity.ERROR,
            'Please select at least one Course'));
            return null;
        }

    }

    /** TODO #2: Declare a read-only property, whose type is a List of
     *		Course_Delivery__c sObjects named deliveries and have it include:
     *      -- an if statement that, if the deliveries property is null
     *         -- Assign the deliveries to a new instance of a list of 
     *				Course_Delivery__c sObjects that will accept as a
     *				parameter a SOQL query that:
     *              -- Selects the Name, Course__r.Name, Instructor__r.Name,
     *                        Location__c, Start_Date__c, Status__c fields
     *              -- From the Course_Delivery__c sObject
     *              -- Where the value of the Course__c field is in the KeySet
     *					for the selectedCourses property and the Status__c is
     *					not equal to 'Cancelled' and the Start_Date__c is
     *					greater to or equal to the keyword TODAY.
     *              -- Order by Start_Date__c
     *              -- Return the deliveries property
     *             Be sure to include the set property and make it private.
     */
    public List<Course_Delivery__c> deliveries {
        get{
            if(deliveries == null){
                deliveries = new List<Course_Delivery__C>([
                    SELECT Name, Course__r.Name, Location__c, Start_Date__c, Status__c
                    FROM Course_Delivery__c
                    WHERE Course__c In :selectedCourses.keySet()
                    AND Status__c != 'Cancelled' and Start_Date__c >= TODAY
                ORDER BY Start_Date__c
                ]);
            }
            return deliveries;
        }
        private set;
    }

    /** TODO #3: Declare a method whose return type is PageReference named
     *		newSearch. Within the method:
     *      -- Declare a variable whose type is a PageReference named PageReference &
     *      	assign it a value of Page.SearchCoursesPage.
     *      -- Call the setRedirect (true) method of the newPage property
     *      -- return the newPage property
     */
    public PageReference newSearch(){
        PageReference newPage = Page.SearchCoursesPage;
        newPage.setRedirect(true);
        return newPage;
    }

    // Wrapper class
    public class CourseWrapper {
        public Course__c course {get; set;}
        public Boolean checked {get; set;}
        public Integer count {get; set;}

        public CourseWrapper(Course__c c) {
            course = c;
            checked = false;
            count = c.Course_Deliveries__r.size();
        }
    }
}