# University Student Information System

A student and exam manager written in MIPS assembly for MARS 4.5. It runs in the console, where you can add students, record passed exams, calculate averages, sort records, and print reports.

Everything lives in one ASM file. The code handles its own record layout and input parsing, moves student records together with their exams during sorting, and uses stack frames for nested calls and recursive exam printing.

## Getting started

You need Java and the **MARS 4.5 executable JAR**, available from the [official releases page](https://github.com/dpetersanderson/MARS/releases). The [MARS website](https://dpetersanderson.github.io/) has the simulator documentation.

Download the JAR separately. The commands below use the filename `Mars4_5.jar`, so adjust them if yours has a different name. In MARS, leave extended/pseudo instructions enabled and delayed branching disabled. These are the default settings.

To use the graphical interface, launch MARS:

```sh
java -jar Mars4_5.jar
```

Open `student_info_system.asm`, assemble it, and run. To start directly from a terminal, place the JAR beside the ASM file and use:

```sh
java -jar Mars4_5.jar nc student_info_system.asm
```

The database starts empty. Choose **0** to load 50 sample students with repeatable exam records, or **1** to enter a student yourself. Option **0** also resets an existing dataset, so any changes you've made in that session will be replaced. Choose **19** to quit.

## Features

The menu includes 17 core operations, sample-data loading, and an extra Top 5 ranking.

| Option | Operation | What it does |
| --- | --- | --- |
| **0** | Populate/reset | Load 50 sample students and their generated exams, replacing the current dataset. |
| **1** | Add a student | Save a unique seven-digit ID, first name, surname, age, and enrollment year. Reuse an inactive slot if one is available. |
| **2** | List students | Print each active student's details, exam count, and weighted average. |
| **3** | Search by ID | Show the matching active student's details, exam count, and average. Use option 17 for individual exams. |
| **4** | Search by surname | Find all active students with an exact, case-sensitive surname match. |
| **5** | Add an exam | Record the exam name, credits, and passing grade after checking the student, available space, and input values. |
| **6** | Edit a student | Change the student's name, surname, age, and enrollment year. The ID stays the same. |
| **7** | Delete a student | Mark the student inactive and make the slot available for reuse. |
| **8** | Weighted average | Calculate a student's average using exam credits as weights. |
| **9** | Best student | Find the highest average among active students with exams. The lower ID wins a tie. |
| **10** | Total credits | Add up a student's exam credits. |
| **11** | Filter by average | List students whose average is strictly above an integer threshold. |
| **12** | Filter by exam count | List students with at least the requested number of passed exams. |
| **13** | Sort by ID | Put active students in ascending ID order, followed by inactive records. |
| **14** | Sort by average | Put active students in descending average order, using ascending ID to break ties. Inactive records come last. |
| **15** | Statistics | Show the active-student count, average age, average exam count, and mean of the available student averages. |
| **16** | Compact report | Print the used-slot count, statistics, best student, and one short row per active student. |
| **17** | Recursive exam list | Print a student's exams through a recursive traversal, including names, credits, and grades. |
| **18** | **Extra: Top 5** | Rank up to five active students with exams by average, breaking ties by ascending ID. The database keeps its current order. |
| **19** | Exit | Close the program. |

### Input rules

Use IDs from `1000000` to `9999999`. Registration checks existing IDs across both active and inactive records, so a deleted student's ID remains reserved until that slot is reused.

The numeric parser reads digits from a string. It rejects empty input, non-digit characters, and values outside the signed 32-bit range before checking the bounds for each field:

| Field | Accepted range |
| --- | --- |
| Age | 16 to 120 |
| Enrollment year | 1900 to `CURRENT_YEAR` (currently 2026) |
| Credits per exam | 1 to 60 |
| Passing grade | 18 to 30 |

Text input uses fixed buffers. First names and surnames each have room for 23 single-byte characters plus a null terminator, while exam names have room for 31 plus the terminator. Longer input is truncated. The routines remove the trailing newline and reject empty strings, but preserve surrounding spaces and accept names made entirely of spaces.

The program reports missing students, full storage, empty datasets, and unavailable averages through console messages. Where a student-ID prompt offers **0 to cancel**, entering zero returns to the main menu.

## How the code is organized

Labeled subroutines divide the source into seven main sections, so the menu calls database operations and calculation helpers without having to handle their storage or input details itself.

| Section | Main routines |
| --- | --- |
| Menu and program flow | `main`, `main_loop`, `menu_*` |
| Input and strings | `read_int_prompt_range`, `parse_uint`, `read_string_prompt`, `trim_newline`, `copy_string_limited`, `strcmp` |
| Student storage and lookup | `clear_database`, `populate_database`, `find_student_by_id_active`, `find_student_by_id_any`, `find_free_slot` |
| Averages, credits, filters, and rankings | `compute_weighted_average`, `compute_total_credits`, `print_fixed_100`, `top_five_students_action` |
| Sorting and record swaps | `sort_by_id`, `sort_by_average`, `swap_students`, `swap_byte_blocks`, `swap_exam_word_block` |
| Statistics and reports | `print_statistics`, `export_report`, `print_compact_student` |
| Recursive exam printing | `recursive_print_action`, `print_exams_recursive`, `print_exam_record` |

The `.eqv` constants set capacities, block sizes, and validation bounds. Storage and console strings sit in `.data`. The `.text` section contains the executable routines, which call each other with `jal` and return with `jr $ra`, saving return addresses and saved registers in stack frames as needed.

### Student and exam storage

Student fields use parallel arrays. In this structure-of-arrays layout, an index identifies the same student across the ID, age, enrollment year, exam count, and active-flag arrays, as well as the fixed-size blocks for first names and surnames.

Exams have their own arrays for names, credits, and grades. Each student gets a contiguous block of 20 exam slots, addressed through a flattened index:

```text
global_exam_index = student_index * MAX_EXAMS + exam_index
numeric_field_offset = global_exam_index * 4
exam_name_offset = global_exam_index * EXAM_NAME_LEN
```

The arrays reserve space for **60 students and 1,200 exams**, using **52,080 bytes** altogether. Console strings, lookup tables, counters, temporary buffers, and the stack use additional memory. Allocation is static.

Deleting a student changes the active flag. The next insertion first looks for an inactive slot, then uses a new slot at the end of the allocated records if space remains. The used-slot counter tracks that allocated portion of the arrays, so deleting a student leaves the counter unchanged.

Reusing a slot replaces the student fields and resets the exam count to zero. Old exam data may still occupy that memory, but the new student's exam count keeps it outside the valid list.

### Averages and statistics

All grade calculations use integers. The stored average is scaled by 100:

```text
average_scaled = floor(100 * sum(grade * credits) / sum(credits))
```

For example, `2444` prints as `24.44`. Division truncates the result, and the formatter adds a leading zero when the fractional part needs one. A student without exams gets the internal value `-1`, displayed as `N/A`.

Both age and exam-count statistics include every active student. For the overall grade statistic, the program averages the already-truncated weighted averages of active students with exams, then truncates that result to two decimal places. Each eligible student therefore contributes one average to this statistic, regardless of how many credits they have earned. An empty group produces `N/A`.

### Sorting and the extra Top 5

Both sorts use bubble sort. A swap moves the student's numeric fields, name blocks, active flag, and every associated exam field together, keeping the parallel arrays consistent after the records change position.

Sorting by average puts active students with exams first, then active students without exams, then inactive records. Comparisons use the stored two-decimal values. If two averages match at that precision, the lower student ID comes first.

Top 5 leaves the records where they are. It repeatedly scans for the best eligible student who hasn't already been selected and stores the chosen indices in a five-entry buffer. Inactive students and students without exams are skipped, and ties follow the same ID rule as best-student selection.

### Recursive exam printing

Option 17 calls `print_exams_recursive` with a student index and an exam index. Each call saves those indices and its return address on the stack before checking whether it has reached the end of the student's exam list.

If an exam remains, the routine prints it and calls itself with the next index. The final call returns without printing. A full list takes 21 calls: 20 print an exam, and the final call handles the base case. A student with no exams gets a separate message.

## Limits and runtime behavior

The database lasts one session. Nothing is saved to disk, and the compact report prints to the console. Exiting the program discards the records, while option 0 replaces them with the sample dataset.

| Setting | Current value |
| --- | --- |
| Student slots | 60, with inactive slots available for reuse |
| Exams per student | 20 |
| Sample students | 50, loaded through option 0 |
| First name / surname buffers | 24 bytes each, including the null terminator |
| Exam name buffer | 32 bytes, including the null terminator |
| Average precision | Two decimal places, truncated |
| Enrollment-year ceiling | `CURRENT_YEAR = 2026`, set in the source |
| Simulator | MARS 4.5, with extended/pseudo instructions enabled and delayed branching disabled |

The enrollment-year check uses the source constant and doesn't read the system clock. To change a storage limit, update the reserved arrays and address calculations along with the relevant constants. Several block sizes are hard-coded, so changing one `.eqv` value alone won't resize the database.
