#!/usr/bin/env python3
"""
Database Population Script for Personnel Management System

This script populates the database with realistic test data:
- 18 departments
- 10 salary grades
- 100 employees with proper hierarchies

Usage:
    python populate_database.py [--base-url URL]

Default base URL: http://localhost:8082
"""

import argparse
import random
import time
from datetime import datetime, timedelta

import requests

# API Configuration
DEFAULT_BASE_URL = "http://localhost:8082"

# Departments to create (18 departments)
DEPARTMENTS = [
    "Executive Office",
    "Human Resources",
    "Finance & Accounting",
    "Information Technology",
    "Software Engineering",
    "Product Management",
    "Quality Assurance",
    "Customer Support",
    "Sales",
    "Marketing",
    "Operations",
    "Research & Development",
    "Legal & Compliance",
    "Facilities Management",
    "Supply Chain",
    "Business Development",
    "Data Analytics",
    "Security",
]

# Salary grades (10 grades from entry level to executive)
SALARY_GRADES = [
    {
        "code": "E1",
        "base_salary": 35000.00,
        "description": "Entry Level - Junior Position",
    },
    {"code": "E2", "base_salary": 42000.00, "description": "Entry Level - Associate"},
    {"code": "M1", "base_salary": 52000.00, "description": "Mid Level - Specialist"},
    {
        "code": "M2",
        "base_salary": 62000.00,
        "description": "Mid Level - Senior Specialist",
    },
    {"code": "M3", "base_salary": 75000.00, "description": "Mid Level - Lead"},
    {"code": "S1", "base_salary": 90000.00, "description": "Senior Level - Manager"},
    {
        "code": "S2",
        "base_salary": 105000.00,
        "description": "Senior Level - Senior Manager",
    },
    {"code": "D1", "base_salary": 125000.00, "description": "Director Level"},
    {"code": "D2", "base_salary": 150000.00, "description": "Senior Director"},
    {
        "code": "X1",
        "base_salary": 200000.00,
        "description": "Executive Level - VP/C-Suite",
    },
]

# First names pool (50 names)
FIRST_NAMES = [
    "James",
    "Mary",
    "John",
    "Patricia",
    "Robert",
    "Jennifer",
    "Michael",
    "Linda",
    "William",
    "Elizabeth",
    "David",
    "Barbara",
    "Richard",
    "Susan",
    "Joseph",
    "Jessica",
    "Thomas",
    "Sarah",
    "Charles",
    "Karen",
    "Christopher",
    "Lisa",
    "Daniel",
    "Nancy",
    "Matthew",
    "Betty",
    "Anthony",
    "Margaret",
    "Mark",
    "Sandra",
    "Donald",
    "Ashley",
    "Steven",
    "Kimberly",
    "Paul",
    "Emily",
    "Andrew",
    "Donna",
    "Joshua",
    "Michelle",
    "Kenneth",
    "Dorothy",
    "Kevin",
    "Carol",
    "Brian",
    "Amanda",
    "George",
    "Melissa",
    "Timothy",
    "Deborah",
]

# Last names pool (50 names)
LAST_NAMES = [
    "Smith",
    "Johnson",
    "Williams",
    "Brown",
    "Jones",
    "Garcia",
    "Miller",
    "Davis",
    "Rodriguez",
    "Martinez",
    "Hernandez",
    "Lopez",
    "Gonzalez",
    "Wilson",
    "Anderson",
    "Thomas",
    "Taylor",
    "Moore",
    "Jackson",
    "Martin",
    "Lee",
    "Perez",
    "Thompson",
    "White",
    "Harris",
    "Sanchez",
    "Clark",
    "Ramirez",
    "Lewis",
    "Robinson",
    "Walker",
    "Young",
    "Allen",
    "King",
    "Wright",
    "Scott",
    "Torres",
    "Nguyen",
    "Hill",
    "Flores",
    "Green",
    "Adams",
    "Nelson",
    "Baker",
    "Hall",
    "Rivera",
    "Campbell",
    "Mitchell",
    "Carter",
    "Roberts",
]

# Roles by level - MUST match database ENUM values: Admin, DepartmentHead, DeputyHead, Employee
ROLES = {
    "executive": ["Admin"],  # Top executives use Admin role
    "director": ["DepartmentHead"],  # Directors are department heads
    "senior": ["DeputyHead"],  # Senior managers are deputy heads
    "mid": ["Employee"],  # Mid-level are regular employees
    "entry": ["Employee"],  # Entry-level are regular employees
}


class DatabasePopulator:
    def __init__(self, base_url):
        self.base_url = base_url.rstrip("/")
        self.created_departments = []
        self.created_salary_grades = []
        self.created_employees = []
        self.department_heads = {}  # dept_id -> employee_id

    def check_health(self):
        """Check if the API is available"""
        try:
            response = requests.get(f"{self.base_url}/health", timeout=10)
            if response.status_code == 200:
                print("✓ API is healthy")
                return True
            else:
                print(f"✗ API returned status {response.status_code}")
                return False
        except requests.exceptions.RequestException as e:
            print(f"✗ Cannot connect to API: {e}")
            return False

    def create_salary_grades(self):
        """Create all salary grades"""
        print("\n=== Creating Salary Grades ===")
        for grade in SALARY_GRADES:
            try:
                response = requests.post(
                    f"{self.base_url}/api/salary-grades", json=grade, timeout=10
                )
                if response.status_code == 201:
                    print(f"  ✓ Created salary grade: {grade['code']}")
                    # Fetch the created grade to get its ID
                    time.sleep(0.1)  # Small delay to avoid overwhelming the API
                else:
                    print(
                        f"  ✗ Failed to create {grade['code']}: {response.status_code} - {response.text}"
                    )
            except requests.exceptions.RequestException as e:
                print(f"  ✗ Error creating {grade['code']}: {e}")

        # Fetch all salary grades to get their IDs
        try:
            response = requests.get(f"{self.base_url}/api/salary-grades", timeout=10)
            if response.status_code == 200:
                self.created_salary_grades = response.json()
                print(f"  → Retrieved {len(self.created_salary_grades)} salary grades")
        except requests.exceptions.RequestException as e:
            print(f"  ✗ Error fetching salary grades: {e}")

    def create_departments(self):
        """Create all departments (without heads initially)"""
        print("\n=== Creating Departments ===")
        for dept_name in DEPARTMENTS:
            try:
                response = requests.post(
                    f"{self.base_url}/api/departments",
                    json={"name": dept_name},
                    timeout=10,
                )
                if response.status_code == 201:
                    print(f"  ✓ Created department: {dept_name}")
                    time.sleep(0.1)
                else:
                    print(
                        f"  ✗ Failed to create {dept_name}: {response.status_code} - {response.text}"
                    )
            except requests.exceptions.RequestException as e:
                print(f"  ✗ Error creating {dept_name}: {e}")

        # Fetch all departments to get their IDs
        try:
            response = requests.get(f"{self.base_url}/api/departments", timeout=10)
            if response.status_code == 200:
                self.created_departments = response.json()
                print(f"  → Retrieved {len(self.created_departments)} departments")
        except requests.exceptions.RequestException as e:
            print(f"  ✗ Error fetching departments: {e}")

    def get_random_hire_date(self, seniority_level):
        """Generate a random hire date based on seniority"""
        today = datetime.now()
        if seniority_level == "executive":
            # Executives: 5-15 years ago
            days_ago = random.randint(5 * 365, 15 * 365)
        elif seniority_level == "director":
            # Directors: 4-12 years ago
            days_ago = random.randint(4 * 365, 12 * 365)
        elif seniority_level == "senior":
            # Senior: 3-8 years ago
            days_ago = random.randint(3 * 365, 8 * 365)
        elif seniority_level == "mid":
            # Mid: 1-5 years ago
            days_ago = random.randint(1 * 365, 5 * 365)
        else:
            # Entry: 0-2 years ago
            days_ago = random.randint(30, 2 * 365)

        hire_date = today - timedelta(days=days_ago)
        return hire_date.strftime("%Y-%m-%d")

    def get_salary_grade_for_level(self, level):
        """Get appropriate salary grade ID for a given level"""
        if not self.created_salary_grades:
            return None

        grade_map = {
            "executive": ["X1", "D2"],
            "director": ["D1", "D2"],
            "senior": ["S1", "S2"],
            "mid": ["M1", "M2", "M3"],
            "entry": ["E1", "E2"],
        }

        target_codes = grade_map.get(level, ["M1"])
        for grade in self.created_salary_grades:
            if grade.get("code") in target_codes:
                return grade.get("id")

        # Fallback to first available grade
        return (
            self.created_salary_grades[0].get("id")
            if self.created_salary_grades
            else None
        )

    def create_employee(
        self, first_name, last_name, role, level, department_id, manager_id=None
    ):
        """Create a single employee"""
        email = f"{first_name.lower()}.{last_name.lower()}@company.com"
        # Ensure unique email by adding a random suffix if needed
        email_base = email.replace("@company.com", "")
        email = f"{email_base}{random.randint(1, 999)}@company.com"

        salary_grade_id = self.get_salary_grade_for_level(level)
        hire_date = self.get_random_hire_date(level)

        employee_data = {
            "first_name": first_name,
            "last_name": last_name,
            "email": email,
            "role": role,
            "department_id": department_id,
            "hire_date": hire_date,
        }

        if manager_id:
            employee_data["manager_id"] = manager_id
        if salary_grade_id:
            employee_data["salary_grade_id"] = salary_grade_id

        try:
            response = requests.post(
                f"{self.base_url}/api/employees", json=employee_data, timeout=10
            )
            if response.status_code == 201:
                return True
            else:
                print(f"    ✗ Failed: {response.status_code} - {response.text[:100]}")
                return False
        except requests.exceptions.RequestException as e:
            print(f"    ✗ Error: {e}")
            return False

    def create_employees(self):
        """Create 100 employees with proper hierarchy"""
        print("\n=== Creating Employees ===")

        if not self.created_departments:
            print("  ✗ No departments available!")
            return

        used_names = set()

        def get_unique_name():
            """Get a unique first/last name combination"""
            attempts = 0
            while attempts < 100:
                first = random.choice(FIRST_NAMES)
                last = random.choice(LAST_NAMES)
                full_name = f"{first} {last}"
                if full_name not in used_names:
                    used_names.add(full_name)
                    return first, last
                attempts += 1
            # Fallback: add a number
            first = random.choice(FIRST_NAMES)
            last = random.choice(LAST_NAMES)
            return first, f"{last}{random.randint(1, 99)}"

        employees_created = 0

        # 1. Create CEO first (no manager) - uses Admin role
        print("  Creating executive leadership...")
        first, last = get_unique_name()
        exec_dept = next(
            (d for d in self.created_departments if "Executive" in d.get("name", "")),
            self.created_departments[0],
        )
        if self.create_employee(first, last, "Admin", "executive", exec_dept["id"]):
            employees_created += 1
            print(f"    ✓ {first} {last} - Admin (CEO)")

        # Fetch employees to get CEO's ID
        time.sleep(0.2)
        response = requests.get(f"{self.base_url}/api/employees", timeout=10)
        employees = response.json() if response.status_code == 200 else []
        # Find the most recently created Admin as CEO
        admins = [e for e in employees if e.get("role") == "Admin"]
        ceo = admins[-1] if admins else None
        ceo_id = ceo["id"] if ceo else None

        # 2. Create other C-suite executives (4 more, report to CEO) - all use Admin role
        c_suite_titles = ["CFO", "CTO", "COO", "CHRO"]
        c_suite_depts = [
            "Finance",
            "Information Technology",
            "Operations",
            "Human Resources",
        ]
        c_suite_ids = []

        for title, dept_hint in zip(c_suite_titles, c_suite_depts):
            first, last = get_unique_name()
            dept = next(
                (d for d in self.created_departments if dept_hint in d.get("name", "")),
                exec_dept,
            )
            if self.create_employee(
                first, last, "Admin", "executive", dept["id"], ceo_id
            ):
                employees_created += 1
                print(f"    ✓ {first} {last} - Admin ({title})")

        # Refresh employee list
        time.sleep(0.2)
        response = requests.get(f"{self.base_url}/api/employees", timeout=10)
        employees = response.json() if response.status_code == 200 else []
        c_suite_ids = [
            e["id"] for e in employees if e.get("role") == "Admin" and e["id"] != ceo_id
        ]

        # 3. Create department heads/directors (one per department, ~18)
        print("  Creating department heads...")
        director_ids = {}

        for dept in self.created_departments:
            dept_name = dept.get("name", "")
            # Skip executive office (already has CEO)
            if "Executive" in dept_name:
                continue

            first, last = get_unique_name()
            role = random.choice(ROLES["director"])

            # Find appropriate C-suite manager (use one of the Admin employees)
            manager_id = ceo_id
            if c_suite_ids:
                # Distribute departments among c-suite admins
                manager_id = random.choice(c_suite_ids) if c_suite_ids else ceo_id

            if self.create_employee(
                first, last, "DepartmentHead", "director", dept["id"], manager_id
            ):
                employees_created += 1
                print(f"    ✓ {first} {last} - Director of {dept_name}")

        # Refresh employee list
        time.sleep(0.2)
        response = requests.get(f"{self.base_url}/api/employees", timeout=10)
        employees = response.json() if response.status_code == 200 else []

        # Map department heads
        for emp in employees:
            if emp.get("role") == "DepartmentHead" and emp.get("department_id"):
                director_ids[emp["department_id"]] = emp["id"]

        # 4. Create senior managers/team leads (~20)
        print("  Creating senior managers and team leads...")
        senior_ids = {}

        for dept in self.created_departments:
            if "Executive" in dept.get("name", ""):
                continue

            # 1-2 senior managers (DeputyHead) per department
            num_seniors = random.randint(1, 2)
            dept_id = dept["id"]
            manager_id = director_ids.get(dept_id, ceo_id)
            senior_ids[dept_id] = []

            for _ in range(num_seniors):
                if employees_created >= 100:
                    break
                first, last = get_unique_name()
                role = "DeputyHead"
                if self.create_employee(
                    first, last, role, "senior", dept_id, manager_id
                ):
                    employees_created += 1
                    print(f"    ✓ {first} {last} - {role}")

        # Refresh employee list
        time.sleep(0.2)
        response = requests.get(f"{self.base_url}/api/employees", timeout=10)
        employees = response.json() if response.status_code == 200 else []

        # Map senior managers (DeputyHead)
        for emp in employees:
            role = emp.get("role", "")
            if role == "DeputyHead" and emp.get("department_id"):
                dept_id = emp["department_id"]
                if dept_id not in senior_ids:
                    senior_ids[dept_id] = []
                senior_ids[dept_id].append(emp["id"])

        # 5. Create mid-level employees (~30)
        print("  Creating mid-level employees...")
        mid_ids = {}

        while employees_created < 55:
            dept = random.choice(self.created_departments)
            if "Executive" in dept.get("name", ""):
                continue

            dept_id = dept["id"]
            # Get a senior manager as manager, or fall back to director
            possible_managers = senior_ids.get(dept_id, [])
            if not possible_managers:
                possible_managers = [director_ids.get(dept_id)]
            manager_id = (
                random.choice([m for m in possible_managers if m])
                if possible_managers
                else None
            )

            first, last = get_unique_name()
            role = "Employee"
            if self.create_employee(first, last, role, "mid", dept_id, manager_id):
                employees_created += 1
                if dept_id not in mid_ids:
                    mid_ids[dept_id] = []
                print(f"    ✓ {first} {last} - {role}")

        # Refresh employee list
        time.sleep(0.2)
        response = requests.get(f"{self.base_url}/api/employees", timeout=10)
        employees = response.json() if response.status_code == 200 else []

        # Map mid-level employees
        for emp in employees:
            role = emp.get("role", "")
            if role == "Employee" and emp.get("department_id"):
                dept_id = emp["department_id"]
                if dept_id not in mid_ids:
                    mid_ids[dept_id] = []
                mid_ids[dept_id].append(emp["id"])

        # 6. Create entry-level employees (remaining to reach 100)
        print("  Creating entry-level employees...")

        while employees_created < 100:
            dept = random.choice(self.created_departments)
            if "Executive" in dept.get("name", ""):
                continue

            dept_id = dept["id"]
            # Get a mid-level or senior manager
            possible_managers = mid_ids.get(dept_id, []) + senior_ids.get(dept_id, [])
            if not possible_managers:
                possible_managers = [director_ids.get(dept_id)]
            manager_id = (
                random.choice([m for m in possible_managers if m])
                if possible_managers
                else None
            )

            first, last = get_unique_name()
            role = "Employee"
            if self.create_employee(first, last, role, "entry", dept_id, manager_id):
                employees_created += 1
                print(f"    ✓ {first} {last} - {role}")

        print(f"\n  → Created {employees_created} employees")

    def assign_department_heads(self):
        """Assign department heads to departments"""
        print("\n=== Assigning Department Heads ===")

        # Fetch latest employee and department data
        try:
            emp_response = requests.get(f"{self.base_url}/api/employees", timeout=10)
            dept_response = requests.get(f"{self.base_url}/api/departments", timeout=10)

            if emp_response.status_code != 200 or dept_response.status_code != 200:
                print("  ✗ Failed to fetch data")
                return

            employees = emp_response.json()
            departments = dept_response.json()

            # Find department heads and assign them
            for dept in departments:
                dept_id = dept["id"]
                dept_name = dept.get("name", "")

                # Find an employee with DepartmentHead role in this department
                head = next(
                    (
                        e
                        for e in employees
                        if e.get("role") == "DepartmentHead"
                        and e.get("department_id") == dept_id
                    ),
                    None,
                )

                # For Executive Office, use CEO
                if not head and "Executive" in dept_name:
                    head = next((e for e in employees if e.get("role") == "CEO"), None)

                if head:
                    try:
                        response = requests.put(
                            f"{self.base_url}/api/departments/{dept_id}",
                            json={"head_id": head["id"]},
                            timeout=10,
                        )
                        if response.status_code == 200:
                            print(
                                f"  ✓ {dept_name}: {head['first_name']} {head['last_name']}"
                            )
                        else:
                            print(
                                f"  ✗ Failed to assign head for {dept_name}: {response.status_code}"
                            )
                    except requests.exceptions.RequestException as e:
                        print(f"  ✗ Error assigning head for {dept_name}: {e}")
                else:
                    print(f"  - {dept_name}: No head found")

        except requests.exceptions.RequestException as e:
            print(f"  ✗ Error: {e}")

    def print_summary(self):
        """Print a summary of the database contents"""
        print("\n" + "=" * 50)
        print("DATABASE POPULATION COMPLETE")
        print("=" * 50)

        try:
            # Fetch final counts
            dept_response = requests.get(f"{self.base_url}/api/departments", timeout=10)
            emp_response = requests.get(f"{self.base_url}/api/employees", timeout=10)
            grade_response = requests.get(
                f"{self.base_url}/api/salary-grades", timeout=10
            )

            if dept_response.status_code == 200:
                depts = dept_response.json()
                print(f"\n📁 Departments: {len(depts)}")
                for d in depts:
                    head_info = ""
                    if d.get("head_id"):
                        head = (
                            next(
                                (
                                    e
                                    for e in emp_response.json()
                                    if e.get("id") == d.get("head_id")
                                ),
                                None,
                            )
                            if emp_response.status_code == 200
                            else None
                        )
                        if head:
                            head_info = (
                                f" (Head: {head['first_name']} {head['last_name']})"
                            )
                    print(f"   • {d.get('name', 'Unknown')}{head_info}")

            if emp_response.status_code == 200:
                emps = emp_response.json()
                print(f"\n👥 Employees: {len(emps)}")

                # Count by role
                role_counts = {}
                for e in emps:
                    role = e.get("role", "Unknown")
                    role_counts[role] = role_counts.get(role, 0) + 1

                print("   By role:")
                for role, count in sorted(role_counts.items(), key=lambda x: -x[1]):
                    print(f"   • {role}: {count}")

            if grade_response.status_code == 200:
                grades = grade_response.json()
                print(f"\n💰 Salary Grades: {len(grades)}")
                for g in grades:
                    print(
                        f"   • {g.get('code', '?')}: ${g.get('base_salary', 0):,.2f} - {g.get('description', '')}"
                    )

        except requests.exceptions.RequestException as e:
            print(f"\n✗ Error fetching summary: {e}")

        print("\n" + "=" * 50)

    def run(self):
        """Run the full population process"""
        print("=" * 50)
        print("PERSONNEL DATABASE POPULATION SCRIPT")
        print("=" * 50)
        print(f"Target API: {self.base_url}")

        if not self.check_health():
            print("\n✗ Aborting: API is not available")
            return False

        self.create_salary_grades()
        self.create_departments()
        self.create_employees()
        self.assign_department_heads()
        self.print_summary()

        return True


def main():
    parser = argparse.ArgumentParser(
        description="Populate the Personnel Management database with test data"
    )
    parser.add_argument(
        "--base-url",
        default=DEFAULT_BASE_URL,
        help=f"API base URL (default: {DEFAULT_BASE_URL})",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be created without making API calls",
    )

    args = parser.parse_args()

    if args.dry_run:
        print("DRY RUN MODE - No changes will be made")
        print("\nWould create:")
        print(f"  • {len(DEPARTMENTS)} departments")
        print(f"  • {len(SALARY_GRADES)} salary grades")
        print("  • 100 employees")
        print(f"\nDepartments: {', '.join(DEPARTMENTS)}")
        print(f"\nSalary Grades: {', '.join(g['code'] for g in SALARY_GRADES)}")
        return

    populator = DatabasePopulator(args.base_url)
    success = populator.run()

    if success:
        print("\n✓ Database population completed successfully!")
    else:
        print("\n✗ Database population failed!")
        exit(1)


if __name__ == "__main__":
    main()
