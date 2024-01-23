actor UniversityFeeCanister {

  // State variables
  let mut students: HashMap<Principal, StudentRecord> = HashMap<Principal, StudentRecord>{};
  let mut universities: HashMap<Text, UniversityRecord> = HashMap<Text, UniversityRecord>{};

  // Student record with basic information
  struct StudentRecord {
    studentID: Nat,
    university: Text,
    feesPaid: Nat64,
  }

  // University record with fees for each semester and course
  struct UniversityRecord {
    semesters: HashMap<Nat, CourseFees>,
  }

  // Fees for a specific semester and course
  struct CourseFees {
    courseID: Text,
    feeAmount: Nat64,
  }

  // Public functions

  // Register a student
  fun registerStudent(studentID: Nat, university: Text) {
    let student = StudentRecord{studentID, university, feesPaid: 0};
    students.insert(caller(), student);
  }

  // Submit fee payment for a specific course
  fun submitFee(courseID: Text, semester: Nat) {
    require(students.contains(caller()));
    let student = students.get(caller());
    let requiredFee = universities.get(student.university).map((u) => u.semesters.get(semester)).flatten().map((c) => c.feeAmount).flatten();
    require(requiredFee >= 0);
    icpTransfer(requiredFee, ic::getPrincipal("feeWallet")).then {
      students.update(caller(), (s) => StudentRecord{s.studentID, s.university, s.feesPaid + requiredFee});
    };
  }

  // University function to validate payments for a student
  fun validatePayment(studentID: Nat): Promise<Nat64> {
    require(universities.contains(caller()));
    let student = students.get(Principal(studentID));
    return if (student != null) {
      return Promise.resolve(student.feesPaid);
    } else {
      return Promise.reject(Error("Student not found"));
    };
  }

  // Administrative functions (restricted to authorized university admins)

  // Add a new university and course fees
  fun addUniversity(name: Text, semesterFees: HashMap<Nat, CourseFees>) {
    require(ic::caller() == ic::getPrincipal("adminAddress"));
    universities.insert(name, UniversityRecord{semesters: semesterFees});
  }

  // Update course fees for a specific semester
  fun updateCourseFee(university: Text, semester: Nat, courseID: Text, newFee: Nat64) {
    require(ic::caller() == ic::getPrincipal("adminAddress"));
    require(universities.contains(university));
    universities.update(university, (u) => UniversityRecord{u.semesters.update(semester, (sc) => CourseFees{courseID, feeAmount: newFee})});
  }

}
