# University Student Information System — MIPS Assembly

.eqv MAX_STUDENTS       60
.eqv INITIAL_STUDENTS   50
.eqv MAX_EXAMS          20
.eqv NAME_LEN           24
.eqv EXAM_NAME_LEN      32
.eqv STUDENT_NAME_BLOCK 24
.eqv EXAM_NAME_BLOCK    32
.eqv EXAM_WORD_BLOCK    80
.eqv EXAM_TEXT_BLOCK    640
.eqv TOP5_SIZE          5
.eqv CURRENT_YEAR       2026
.eqv MAX_CREDITS_INPUT  60

.data

# Number of student slots allocated so far.
student_count:      .word 0

# Student numeric fields. The same index identifies the same student
# across all parallel arrays.
student_ids:        .space 240
student_ages:       .space 240
student_years:      .space 240
student_exam_counts:.space 240
student_active:     .space 240

# Student text fields: 60 blocks of 24 bytes each.
first_names:        .space 1440     # 24 bytes per first name, including the null terminator, for 60 students.
last_names:         .space 1440     # 60 * 24 = 1440

# Flattened exams: index = student_index * MAX_EXAMS + exam_index.
# Each student has space for up to 20 exam names, credit values, and grades.
exam_names:         .space 38400
exam_credits:       .space 4800
exam_grades:        .space 4800

input_buffer:       .space 64

# Temporary Top 5 buffer containing student indices only.
top5_indices:       .space 20

# Lookup tables used only to populate the sample database.
first_name_ptrs:
    .word first_alex, first_bianca, first_carlo, first_diana, first_elena
    .word first_fabio, first_giulia, first_luca, first_marta, first_nicola
last_name_ptrs:
    .word last_rossi, last_bianchi, last_ferrari, last_esposito, last_romano
    .word last_colombo, last_ricci, last_marino, last_greco, last_bruno
exam_name_ptrs:
    .word exam_calc, exam_prog, exam_arch, exam_alg, exam_db
    .word exam_net, exam_os, exam_phys, exam_math, exam_eng


# Sample first names, surnames, and subjects used during database population.
first_alex:     .asciiz "Alex"
first_bianca:   .asciiz "Bianca"
first_carlo:    .asciiz "Carlo"
first_diana:    .asciiz "Diana"
first_elena:    .asciiz "Elena"
first_fabio:    .asciiz "Fabio"
first_giulia:   .asciiz "Giulia"
first_luca:     .asciiz "Luca"
first_marta:    .asciiz "Marta"
first_nicola:   .asciiz "Nicola"

last_rossi:     .asciiz "Rossi"
last_bianchi:   .asciiz "Bianchi"
last_ferrari:   .asciiz "Ferrari"
last_esposito:  .asciiz "Esposito"
last_romano:    .asciiz "Romano"
last_colombo:   .asciiz "Colombo"
last_ricci:     .asciiz "Ricci"
last_marino:    .asciiz "Marino"
last_greco:     .asciiz "Greco"
last_bruno:     .asciiz "Bruno"

exam_calc:      .asciiz "Calculus"
exam_prog:      .asciiz "Programming"
exam_arch:      .asciiz "Computer Architecture"
exam_alg:       .asciiz "Algorithms"
exam_db:        .asciiz "Databases"
exam_net:       .asciiz "Networks"
exam_os:        .asciiz "Operating Systems"
exam_phys:      .asciiz "Physics"
exam_math:      .asciiz "Discrete Mathematics"
exam_eng:       .asciiz "English"

# Console menu.
# Only the final menu fragment adds a null terminator. main prints the menu
# with one syscall, which reads the entire string up to that terminator.
menu_text:
    .ascii "\n ___ _____ _   _ ___  ___ _  _ _____   ___ _  _ ___ ___    _____   _____ _____ ___ __  __ \n"
    .ascii "/ __|_   _| | | |   \\| __| \\| |_   _| |_ _| \\| | __/ _ \\  / __\\ \\ / / __|_   _| __|  \\/  |\n"
    .ascii "\\__ \\ | | | |_| | |) | _|| .` | | |    | || .` | _| (_) | \\__ \\\\ V /\\__ \\ | | | _|| |\\/| |\n"
    .ascii "|___/ |_|  \\___/|___/|___|_|\\_| |_|   |___|_|\\_|_| \\___/  |___/ |_| |___/ |_| |___|_|  |_|\n"
    .ascii "                                                                                          \n"
    .ascii "+=======================================================================+\n"
    .ascii "|                UNIVERSITY STUDENT INFORMATION SYSTEM                 |\n"
    .ascii "+=======================================================================+\n"
    .ascii "| DATA MANAGEMENT                                                      |\n"
    .ascii "|  0. Populate/reset database                                          |\n"
    .ascii "|  1. Insert a new student                                             |\n"
    .ascii "|  2. Print all students                                               |\n"
    .ascii "+-----------------------------------------------------------------------+\n"
    .ascii "| SEARCH AND EDIT                                                      |\n"
    .ascii "|  3. Search a student by ID                                           |\n"
    .ascii "|  4. Search students by surname                                       |\n"
    .ascii "|  5. Add a passed exam to a student                                   |\n"
    .ascii "|  6. Edit student personal information                                |\n"
    .ascii "|  7. Delete a student logically (mark as inactive)                    |\n"
    .ascii "+-----------------------------------------------------------------------+\n"
    .ascii "| ANALYSIS AND REPORTING                                               |\n"
    .ascii "|  8.  Compute weighted average for one student                        |\n"
    .ascii "|  9.  Compute the best student by weighted average                    |\n"
    .ascii "| 10.  Compute total credits earned by one student                     |\n"
    .ascii "| 11.  Print students above a given average threshold                  |\n"
    .ascii "| 12.  Print students with at least N passed exams                     |\n"
    .ascii "| 13.  Sort students by ID                                             |\n"
    .ascii "| 14.  Sort students by weighted average                               |\n"
    .ascii "| 15.  Print statistics                                                |\n"
    .ascii "| 16.  Export a compact textual report to screen                       |\n"
    .ascii "| 17.  Recursive print of a student's exam list                        |\n"
    .ascii "| 18.  Top 5 students by weighted average                              |\n"
    .ascii "+-----------------------------------------------------------------------+\n"
    .ascii "| SYSTEM                                                               |\n"
    .ascii "| 19. Exit                                                             |\n"
    .ascii "+=======================================================================+\n"
    .asciiz "| Choice (0-19): "

# Console messages.
msg_welcome:        .asciiz "[INFO] Use option 0 first to populate the database.\n"
msg_invalid_choice: .asciiz "[ERROR] Invalid choice. Please enter a value between 0 and 19.\n"
msg_populated:      .asciiz "[INFO] Database populated with 50 active students.\n"
msg_empty_db:       .asciiz "Database is empty. Use option 0 first.\n"
msg_full_db:        .asciiz "Database is full.\n"
msg_inserted:       .asciiz "Student inserted.\n"
msg_updated:        .asciiz "Student updated.\n"
msg_deleted:        .asciiz "Student marked as inactive.\n"
msg_added_exam:     .asciiz "Exam added.\n"
msg_not_found:      .asciiz "Student not found.\n"
msg_no_matches:     .asciiz "No matching students.\n"
msg_duplicate_id:   .asciiz "Invalid ID: this student ID already exists.\n"
msg_empty_input:    .asciiz "Input cannot be empty.\n"
msg_exam_full:      .asciiz "This student already has 20 exams.\n"
msg_no_exams:       .asciiz "No exams available for this student.\n"
msg_no_best:        .asciiz "No active student with exams was found.\n"
msg_sorted_id:      .asciiz "Students sorted by ID.\n"
msg_sorted_avg:     .asciiz "Students sorted by weighted average.\n"
msg_report_title:   .asciiz "\n===== COMPACT REPORT =====\n"
msg_stats_title:    .asciiz "\n===== STATS =====\n"
msg_exam_title:     .asciiz "\nExam list:\n"
msg_invalid_number: .asciiz "[ERROR] Please enter digits only.\n"
msg_invalid_range:  .asciiz "[ERROR] Value outside the allowed range. Try again.\n"

# Operation headings.
title_populate:
    .ascii "\n ___  ___  ___ _   _ _      _ _____ ___ \n"
    .ascii "| _ \\/ _ \\| _ \\ | | | |    /_\\_   _| __|\n"
    .ascii "|  _/ (_) |  _/ |_| | |__ / _ \\| | | _| \n"
    .ascii "|_|  \\___/|_|  \\___/|____/_/ \\_\\_| |___|\n"
    .ascii "                                        \n"
    .asciiz "\n"

title_insert:
    .ascii "\n ___ _  _ ___ ___ ___ _____ \n"
    .ascii "|_ _| \\| / __| __| _ \\_   _|\n"
    .ascii " | || .` \\__ \\ _||   / | |  \n"
    .ascii "|___|_|\\_|___/___|_|_\\ |_|  \n"
    .ascii "                            \n"
    .asciiz "\n"

title_print_all:
    .ascii "\n ___ ___ ___ _  _ _____     _   _    _    \n"
    .ascii "| _ \\ _ \\_ _| \\| |_   _|   /_\\ | |  | |   \n"
    .ascii "|  _/   /| || .` | | |    / _ \\| |__| |__ \n"
    .ascii "|_| |_|_\\___|_|\\_| |_|   /_/ \\_\\____|____|\n"
    .ascii "                                          \n"
    .asciiz "\n"

title_search_id:
    .ascii "\n ___ ___   _   ___  ___ _  _   ___ ___  \n"
    .ascii "/ __| __| /_\\ | _ \\/ __| || | |_ _|   \\ \n"
    .ascii "\\__ \\ _| / _ \\|   / (__| __ |  | || |) |\n"
    .ascii "|___/___/_/ \\_\\_|_\\\\___|_||_| |___|___/ \n"
    .ascii "                                        \n"
    .asciiz "\n"

title_search_surname:
    .ascii "\n ___ ___   _   ___  ___ _  _   ___ _   _ ___ _  _   _   __  __ ___ \n"
    .ascii "/ __| __| /_\\ | _ \\/ __| || | / __| | | | _ \\ \\| | /_\\ |  \\/  | __|\n"
    .ascii "\\__ \\ _| / _ \\|   / (__| __ | \\__ \\ |_| |   / .` |/ _ \\| |\\/| | _| \n"
    .ascii "|___/___/_/ \\_\\_|_\\\\___|_||_| |___/\\___/|_|_\\_|\\_/_/ \\_\\_|  |_|___|\n"
    .ascii "                                                                   \n"
    .asciiz "\n"

title_add_exam:
    .ascii "\n   _   ___  ___    _____  __   _   __  __ \n"
    .ascii "  /_\\ |   \\|   \\  | __\\ \\/ /  /_\\ |  \\/  |\n"
    .ascii " / _ \\| |) | |) | | _| >  <  / _ \\| |\\/| |\n"
    .ascii "/_/ \\_\\___/|___/  |___/_/\\_\\/_/ \\_\\_|  |_|\n"
    .ascii "                                          \n"
    .asciiz "\n"

title_edit:
    .ascii "\n ___ ___ ___ _____   ___ _____ _   _ ___  ___ _  _ _____ \n"
    .ascii "| __|   \\_ _|_   _| / __|_   _| | | |   \\| __| \\| |_   _|\n"
    .ascii "| _|| |) | |  | |   \\__ \\ | | | |_| | |) | _|| .` | | |  \n"
    .ascii "|___|___/___| |_|   |___/ |_|  \\___/|___/|___|_|\\_| |_|  \n"
    .ascii "                                                         \n"
    .asciiz "\n"

title_delete:
    .ascii "\n ___  ___ _    ___ _____ ___   ___ _____ _   _ ___  ___ _  _ _____ \n"
    .ascii "|   \\| __| |  | __|_   _| __| / __|_   _| | | |   \\| __| \\| |_   _|\n"
    .ascii "| |) | _|| |__| _|  | | | _|  \\__ \\ | | | |_| | |) | _|| .` | | |  \n"
    .ascii "|___/|___|____|___| |_| |___| |___/ |_|  \\___/|___/|___|_|\\_| |_|  \n"
    .ascii "                                                                   \n"
    .asciiz "\n"

title_average:
    .ascii "\n   ___   _____ ___    _   ___ ___ \n"
    .ascii "  /_\\ \\ / / __| _ \\  /_\\ / __| __|\n"
    .ascii " / _ \\ V /| _||   / / _ \\ (_ | _| \n"
    .ascii "/_/ \\_\\_/ |___|_|_\\/_/ \\_\\___|___|\n"
    .ascii "                                  \n"
    .asciiz "\n"

title_best:
    .ascii "\n ___ ___ ___ _____   ___ _____ _   _ ___  ___ _  _ _____ \n"
    .ascii "| _ ) __/ __|_   _| / __|_   _| | | |   \\| __| \\| |_   _|\n"
    .ascii "| _ \\ _|\\__ \\ | |   \\__ \\ | | | |_| | |) | _|| .` | | |  \n"
    .ascii "|___/___|___/ |_|   |___/ |_|  \\___/|___/|___|_|\\_| |_|  \n"
    .ascii "                                                         \n"
    .asciiz "\n"

title_total_credits:
    .ascii "\n _____ ___ _____ _   _       ___ ___ ___ ___ ___ _____ ___ \n"
    .ascii "|_   _/ _ \\_   _/_\\ | |     / __| _ \\ __|   \\_ _|_   _/ __|\n"
    .ascii "  | || (_) || |/ _ \\| |__  | (__|   / _|| |) | |  | | \\__ \\\n"
    .ascii "  |_| \\___/ |_/_/ \\_\\____|  \\___|_|_\\___|___/___| |_| |___/\n"
    .ascii "                                                           \n"
    .asciiz "\n"

title_above_threshold:
    .ascii "\n   _   ___  _____   _____   _____ _  _ ___ ___ ___ _  _  ___  _    ___  \n"
    .ascii "  /_\\ | _ )/ _ \\ \\ / / __| |_   _| || | _ \\ __/ __| || |/ _ \\| |  |   \\ \n"
    .ascii " / _ \\| _ \\ (_) \\ V /| _|    | | | __ |   / _|\\__ \\ __ | (_) | |__| |) |\n"
    .ascii "/_/ \\_\\___/\\___/ \\_/ |___|   |_| |_||_|_|_\\___|___/_||_|\\___/|____|___/ \n"
    .ascii "                                                                        \n"
    .asciiz "\n"

title_min_exams:
    .ascii "\n __  __ ___ _  _   _____  __   _   __  __ ___ \n"
    .ascii "|  \\/  |_ _| \\| | | __\\ \\/ /  /_\\ |  \\/  / __|\n"
    .ascii "| |\\/| || || .` | | _| >  <  / _ \\| |\\/| \\__ \\\n"
    .ascii "|_|  |_|___|_|\\_| |___/_/\\_\\/_/ \\_\\_|  |_|___/\n"
    .ascii "                                              \n"
    .asciiz "\n"

title_sort_id:
    .ascii "\n ___  ___  ___ _____   _____   __  ___ ___  \n"
    .ascii "/ __|/ _ \\| _ \\_   _| | _ ) \\ / / |_ _|   \\ \n"
    .ascii "\\__ \\ (_) |   / | |   | _ \\\\ V /   | || |) |\n"
    .ascii "|___/\\___/|_|_\\ |_|   |___/ |_|   |___|___/ \n"
    .ascii "                                            \n"
    .asciiz "\n"

title_sort_avg:
    .ascii "\n ___  ___  ___ _____   _____   __    ___   _____ \n"
    .ascii "/ __|/ _ \\| _ \\_   _| | _ ) \\ / /   /_\\ \\ / / __|\n"
    .ascii "\\__ \\ (_) |   / | |   | _ \\\\ V /   / _ \\ V / (_ |\n"
    .ascii "|___/\\___/|_|_\\ |_|   |___/ |_|   /_/ \\_\\_/ \\___|\n"
    .ascii "                                                 \n"
    .asciiz "\n"

title_statistics:
    .ascii "\n ___ _____ _ _____ ___ ___ _____ ___ ___ ___ \n"
    .ascii "/ __|_   _/_\\_   _|_ _/ __|_   _|_ _/ __/ __|\n"
    .ascii "\\__ \\ | |/ _ \\| |  | |\\__ \\ | |  | | (__\\__ \\\n"
    .ascii "|___/ |_/_/ \\_\\_| |___|___/ |_| |___\\___|___/\n"
    .ascii "                                             \n"
    .asciiz "\n"

title_report:
    .ascii "\n ___ ___ ___  ___  ___ _____ \n"
    .ascii "| _ \\ __| _ \\/ _ \\| _ \\_   _|\n"
    .ascii "|   / _||  _/ (_) |   / | |  \n"
    .ascii "|_|_\\___|_|  \\___/|_|_\\ |_|  \n"
    .ascii "                             \n"
    .asciiz "\n"

title_recursive:
    .ascii "\n ___ ___ ___ _   _ ___  ___ _____   _____   ___ ___ ___ _  _ _____ \n"
    .ascii "| _ \\ __/ __| | | | _ \\/ __|_ _\\ \\ / / __| | _ \\ _ \\_ _| \\| |_   _|\n"
    .ascii "|   / _| (__| |_| |   /\\__ \\| | \\ V /| _|  |  _/   /| || .` | | |  \n"
    .ascii "|_|_\\___\\___|\\___/|_|_\\|___/___| \\_/ |___| |_| |_|_\\___|_|\\_| |_|  \n"
    .ascii "                                                                   \n"
    .asciiz "\n"

title_top5:
    .ascii "\n _____ ___  ___   ___ \n"
    .ascii "|_   _/ _ \\| _ \\ | __|\n"
    .ascii "  | || (_) |  _/ |__ \\\n"
    .ascii "  |_| \\___/|_|   |___/\n"
    .ascii "                      \n"
    .asciiz "\n"

# Prompts for user operations.
prompt_id:          .asciiz "Student ID (7 digits): "
prompt_id_cancel:   .asciiz "Student ID (7 digits, 0 to cancel): "
prompt_first:       .asciiz "First name: "
prompt_last:        .asciiz "Last name/surname: "
prompt_age:         .asciiz "Age: "
prompt_year:        .asciiz "Year of enrollment: "
prompt_exam_name:   .asciiz "Exam name: "
prompt_credits:     .asciiz "Credits: "
prompt_grade:       .asciiz "Grade (18..30): "
prompt_threshold:   .asciiz "Average threshold (integer grade): "
prompt_min_exams:   .asciiz "Minimum number of passed exams: "

# Labels for displayed record fields and statistics.
label_id:           .asciiz "ID: "
label_name:         .asciiz " | Name: "
label_age:          .asciiz " | Age: "
label_year:         .asciiz " | Enrollment: "
label_exams:        .asciiz " | Exams: "
label_avg:          .asciiz " | Avg: "
label_avg_plain:    .asciiz "Average: "
label_credits:      .asciiz "Credits: "
label_grade:        .asciiz " | Grade: "
label_total_active: .asciiz "Total active students: "
label_avg_age:      .asciiz "Average age: "
label_avg_exams:    .asciiz "Average exams per student: "
label_avg_grade:    .asciiz "Average weighted grade: "
label_total_credits:.asciiz "Total credits: "
label_best:         .asciiz "Best student: "
label_slots:        .asciiz "Used slots: "

# Separators used to format console output.
sep_dash:           .asciiz " - "
sep_space:          .asciiz " "
sep_newline:        .asciiz "\n"
sep_dot:            .asciiz "."
sep_open:           .asciiz "["
sep_close:          .asciiz "] "
not_available:      .asciiz "N/A"

.text
.globl main

main:
# ==========================================================
# SECTION A - APPLICATION CONTROL (main and menu loop)
# ==========================================================
#  __  __   _   ___ _  _
# |  \/  | /_\ |_ _| \| |
# | |\/| |/ _ \ | || .` |
# |_|  |_/_/ \_\___|_|\_|
# Each choice jumps to a menu_* handler, which calls an operation and returns to main_loop.

    li $v0, 4
    la $a0, msg_welcome
    syscall

# Main interaction loop.
main_loop:
    jal print_menu
    move $t0, $v0

    li $t1, 0
    beq $t0, $t1, menu_populate
    li $t1, 1
    beq $t0, $t1, menu_insert
    li $t1, 2
    beq $t0, $t1, menu_print_all
    li $t1, 3
    beq $t0, $t1, menu_search_id
    li $t1, 4
    beq $t0, $t1, menu_search_surname
    li $t1, 5
    beq $t0, $t1, menu_add_exam
    li $t1, 6
    beq $t0, $t1, menu_edit
    li $t1, 7
    beq $t0, $t1, menu_delete
    li $t1, 8
    beq $t0, $t1, menu_average
    li $t1, 9
    beq $t0, $t1, menu_best
    li $t1, 10
    beq $t0, $t1, menu_total_credits
    li $t1, 11
    beq $t0, $t1, menu_above_threshold
    li $t1, 12
    beq $t0, $t1, menu_at_least_exams
    li $t1, 13
    beq $t0, $t1, menu_sort_id
    li $t1, 14
    beq $t0, $t1, menu_sort_average
    li $t1, 15
    beq $t0, $t1, menu_statistics
    li $t1, 16
    beq $t0, $t1, menu_report
    li $t1, 17
    beq $t0, $t1, menu_recursive
    li $t1, 18
    beq $t0, $t1, menu_top5
    li $t1, 19
    beq $t0, $t1, exit_program

    li $v0, 4
    la $a0, msg_invalid_choice
    syscall
    j main_loop

menu_populate:
    li $v0, 4
    la $a0, title_populate
    syscall
    jal populate_database
    j main_loop

menu_insert:
    li $v0, 4
    la $a0, title_insert
    syscall
    jal insert_student
    j main_loop

menu_print_all:
    li $v0, 4
    la $a0, title_print_all
    syscall
    jal print_all_students
    j main_loop

menu_search_id:
    li $v0, 4
    la $a0, title_search_id
    syscall
    jal search_by_id_action
    j main_loop

menu_search_surname:
    li $v0, 4
    la $a0, title_search_surname
    syscall
    jal search_by_surname_action
    j main_loop

menu_add_exam:
    li $v0, 4
    la $a0, title_add_exam
    syscall
    jal add_exam_action
    j main_loop

menu_edit:
    li $v0, 4
    la $a0, title_edit
    syscall
    jal edit_student_action
    j main_loop

menu_delete:
    li $v0, 4
    la $a0, title_delete
    syscall
    jal delete_student_action
    j main_loop

menu_average:
    li $v0, 4
    la $a0, title_average
    syscall
    jal average_action
    j main_loop

menu_best:
    li $v0, 4
    la $a0, title_best
    syscall
    jal best_student_action
    j main_loop

menu_total_credits:
    li $v0, 4
    la $a0, title_total_credits
    syscall
    jal total_credits_action
    j main_loop

menu_above_threshold:
    li $v0, 4
    la $a0, title_above_threshold
    syscall
    jal above_threshold_action
    j main_loop

menu_at_least_exams:
    li $v0, 4
    la $a0, title_min_exams
    syscall
    jal at_least_exams_action
    j main_loop

menu_sort_id:
    li $v0, 4
    la $a0, title_sort_id
    syscall
    jal sort_by_id
    li $v0, 4
    la $a0, msg_sorted_id
    syscall
    j main_loop

menu_sort_average:
    li $v0, 4
    la $a0, title_sort_avg
    syscall
    jal sort_by_average
    li $v0, 4
    la $a0, msg_sorted_avg
    syscall
    j main_loop

menu_statistics:
    li $v0, 4
    la $a0, title_statistics
    syscall
    jal print_statistics
    j main_loop

menu_report:
    li $v0, 4
    la $a0, title_report
    syscall
    jal export_report
    j main_loop

menu_recursive:
    li $v0, 4
    la $a0, title_recursive
    syscall
    jal recursive_print_action
    j main_loop

menu_top5:
    li $v0, 4
    la $a0, title_top5
    syscall
    jal top_five_students_action
    j main_loop

exit_program:
    li $v0, 10
    syscall

# ==========================================================
# SECTION B - INPUT/OUTPUT AND STRINGS
# ==========================================================

print_menu:
    addiu $sp, $sp, -4 		# Reserve 4 stack bytes for $ra, which the nested call would overwrite.
    sw $ra, 0($sp)
# Menu input loop: report invalid numbers or choices outside 0..19
# and read another choice without terminating the program.
print_menu_loop:
    li $v0, 4
    la $a0, menu_text
    syscall

print_menu_read_choice:
    la $a0, input_buffer
    li $a1, 64
    li $v0, 8
    syscall

    la $a0, input_buffer
    jal trim_newline
    la $a0, input_buffer
    jal parse_uint
    beq $v1, $zero, print_menu_bad_choice
    li $t0, 19
    bgt $v0, $t0, print_menu_bad_choice

    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

print_menu_bad_choice:
    li $v0, 4
    la $a0, msg_invalid_choice
    syscall
    j print_menu_read_choice

# Read an integer as text and repeat the prompt until the value is valid.
# Arguments: $a0 = prompt, $a1 = lower bound, $a2 = upper bound.
read_int_prompt_range:
    addiu $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2

# Integer input loop: read a string, parse it, and repeat until
# the result falls within the bounds supplied by the caller.
read_int_prompt_range_loop:
    li $v0, 4
    move $a0, $s0
    syscall

    la $a0, input_buffer
    li $a1, 64
    li $v0, 8
    syscall

    la $a0, input_buffer
    jal trim_newline
    la $a0, input_buffer
    jal parse_uint
    beq $v1, $zero, read_int_prompt_bad_number
    blt $v0, $s1, read_int_prompt_bad_range
    bgt $v0, $s2, read_int_prompt_bad_range

read_int_prompt_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addiu $sp, $sp, 16
    jr $ra

read_int_prompt_bad_number:
    li $v0, 4
    la $a0, msg_invalid_number
    syscall
    j read_int_prompt_range_loop

read_int_prompt_bad_range:
    li $v0, 4
    la $a0, msg_invalid_range
    syscall
    j read_int_prompt_range_loop

parse_uint:
    move $t0, $a0
    li $t1, 0
    li $t2, 0
# Parse one character at a time, building the decimal value with
# accumulator = accumulator * 10 + current_digit.
parse_uint_loop:
    lb $t3, 0($t0)
    beq $t3, $zero, parse_uint_done_loop
    li $t4, 48
    blt $t3, $t4, parse_uint_bad
    li $t4, 57
    bgt $t3, $t4, parse_uint_bad
    addiu $t3, $t3, -48
    li $t4, 214748364    # Largest safe accumulator before multiplying by 10.
    bgt $t1, $t4, parse_uint_bad    # Reject values that would overflow a signed 32-bit integer.
    bne $t1, $t4, parse_uint_safe_digit    # Below the limit, any decimal digit is safe.
    li $t5, 7    # Largest final digit allowed for 2147483647.
    bgt $t3, $t5, parse_uint_bad    # Reject 2147483648 and larger values.
parse_uint_safe_digit:
    li $t4, 10
    mul $t1, $t1, $t4
    addu $t1, $t1, $t3
    addiu $t2, $t2, 1
    addiu $t0, $t0, 1
    j parse_uint_loop
parse_uint_done_loop:
    beq $t2, $zero, parse_uint_bad
    move $v0, $t1
    li $v1, 1
    jr $ra
parse_uint_bad:
    move $v0, $zero
    move $v1, $zero
    jr $ra

# Read a string, remove its trailing newline, and reject empty input.
read_string_prompt:
    addiu $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)

    move $s2, $a0
    move $s0, $a1
    move $s1, $a2
# Text input loop: repeat the prompt until at least one character
# remains after removing the newline. Spaces are preserved.
read_string_prompt_loop:
    move $a0, $s2
    li $v0, 4
    syscall

    move $a0, $s0
    move $a1, $s1
    li $v0, 8
    syscall

    move $a0, $s0
    jal trim_newline
    lb $t0, 0($s0)
    bne $t0, $zero, read_string_prompt_done_input
    li $v0, 4
    la $a0, msg_empty_input
    syscall
    j read_string_prompt_loop

read_string_prompt_done_input:
    move $v0, $s0

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addiu $sp, $sp, 16
    jr $ra

trim_newline:
    move $t0, $a0
# Scan the buffer until a newline or null terminator is found.
# Replace the newline with a null terminator.
trim_newline_loop:
    lb $t1, 0($t0)
    beq $t1, $zero, trim_newline_done
    li $t2, 10
    beq $t1, $t2, trim_newline_replace
    addiu $t0, $t0, 1
    j trim_newline_loop
trim_newline_replace:
    sb $zero, 0($t0)
trim_newline_done:
    jr $ra

# Copy at most max_len - 1 bytes and always add a null terminator.
copy_string_limited:
    addiu $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $ra, 12($sp)

    move $s0, $a0
    move $s1, $a1
    addiu $s2, $a2, -1
# Copy bytes from source to destination, stopping at the terminator
# or after max_len - 1 bytes to leave room for the final null byte.
copy_string_loop:
    beq $s2, $zero, copy_string_force_zero
    lb $t0, 0($s0)
    sb $t0, 0($s1)
    beq $t0, $zero, copy_string_done
    addiu $s0, $s0, 1
    addiu $s1, $s1, 1
    addiu $s2, $s2, -1
    j copy_string_loop
copy_string_force_zero:
    sb $zero, 0($s1)
copy_string_done:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $ra, 12($sp)
    addiu $sp, $sp, 16
    jr $ra

strcmp:
# Compare one byte from each string per iteration. Stop at the first
# difference or when both strings reach their null terminator.
strcmp_loop:
    lb $t0, 0($a0)
    lb $t1, 0($a1)
    bne $t0, $t1, strcmp_not_equal
    beq $t0, $zero, strcmp_equal
    addiu $a0, $a0, 1
    addiu $a1, $a1, 1
    j strcmp_loop
strcmp_equal:
    move $v0, $zero
    jr $ra
strcmp_not_equal:
    li $v0, 1
    jr $ra

# ===================================================================
# SECTION C - DATABASE MANAGEMENT (RESET, POPULATION, AND LOOKUP)
# ===================================================================

clear_database:
    li $t0, 0

# Reset all student slots by clearing active flags, exam counts, and numeric fields.
clear_database_loop:
    li $t9, MAX_STUDENTS
    bge $t0, $t9, clear_database_done
    sll $t1, $t0, 2     # Multiply the index by 4 to obtain a word-array byte offset.

    la $t2, student_ids
    addu $t3, $t2, $t1
    sw $zero, 0($t3)
    la $t2, student_ages
    addu $t3, $t2, $t1
    sw $zero, 0($t3)
    la $t2, student_years
    addu $t3, $t2, $t1
    sw $zero, 0($t3)
    la $t2, student_exam_counts
    addu $t3, $t2, $t1
    sw $zero, 0($t3)
    la $t2, student_active
    addu $t3, $t2, $t1
    sw $zero, 0($t3)

    addiu $t0, $t0, 1       # Increment without a signed-overflow trap.
    j clear_database_loop
clear_database_done:
    sw $zero, student_count
    jr $ra

# Option 0 - Populate the database with deterministic sample records.
# Generate student IDs 1000001..1000050 and repeatable names and exams
# so each run starts with the same sample dataset.
populate_database:
    addiu $sp, $sp, -20     # Reserve five 32-bit words on the stack: 5 * 4 = 20 bytes.
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)

    jal clear_database

    li $s0, 0
# Outer population loop: generate one sample student per iteration
# using deterministic formulas for repeatable results.
populate_student_loop:
    li $t9, INITIAL_STUDENTS
    bge $s0, $t9, populate_done

    sll $t0, $s0, 2  # Byte offset into the parallel word arrays.

    # Initialize the current student ID, age, enrollment year, and active flag.
    # The active flag is 1 for an active student and 0 for an inactive slot.
    la $t1, student_ids
    addu $t2, $t1, $t0
    li $t3, 1000001         # First sample student ID. Subsequent records receive consecutive seven-digit IDs.
    addu $t3, $t3, $s0
    sw $t3, 0($t2)

    la $t1, student_ages
    addu $t2, $t1, $t0
    li $t9, 12
    div $s0, $t9
    mfhi $t3
    addiu $t3, $t3, 19
    sw $t3, 0($t2)

    la $t1, student_years
    addu $t2, $t1, $t0
    li $t9, 8
    div $s0, $t9
    mfhi $t3
    addiu $t3, $t3, 2018
    sw $t3, 0($t2)

    la $t1, student_active
    addu $t2, $t1, $t0
    li $t3, 1
    sw $t3, 0($t2)

    la $t1, student_exam_counts
    addu $t2, $t1, $t0
    li $t9, 18
    div $s0, $t9
    mfhi $s2
    addiu $s2, $s2, 3
    sw $s2, 0($t2)

    # Copy a first name and surname from the lookup tables into the student slot.
    li $t9, 10
    div $s0, $t9
    mfhi $t3
    sll $t3, $t3, 2
    la $t4, first_name_ptrs
    addu $t4, $t4, $t3
    lw $a0, 0($t4)
    la $a1, first_names
    sll $t5, $s0, 4
    sll $t6, $s0, 3
    addu $t5, $t5, $t6
    addu $a1, $a1, $t5
    li $a2, NAME_LEN
    jal copy_string_limited

    li $t9, 10
    div $s0, $t9
    mfhi $t3
    sll $t3, $t3, 2
    la $t4, last_name_ptrs
    addu $t4, $t4, $t3
    lw $a0, 0($t4)
    la $a1, last_names
    sll $t5, $s0, 4
    sll $t6, $s0, 3
    addu $t5, $t5, $t6
    addu $a1, $a1, $t5
    li $a2, NAME_LEN
    jal copy_string_limited

    li $s1, 0
# Inner population loop: generate each exam for the current student
# at flattened index student_index * MAX_EXAMS + exam_index.
populate_exam_loop:
    bge $s1, $s2, populate_next_student
    # Compute the flattened exam index.
    # global_exam_index = student_index * 20 + exam_index.
    sll $s3, $s0, 4
    sll $t9, $s0, 2
    addu $s3, $s3, $t9
    addu $s3, $s3, $s1

    li $t9, 10
    div $s1, $t9
    mfhi $t0
    sll $t0, $t0, 2
    la $t1, exam_name_ptrs
    addu $t1, $t1, $t0
    lw $a0, 0($t1)
    la $a1, exam_names
    sll $t2, $s3, 5
    addu $a1, $a1, $t2
    li $a2, EXAM_NAME_LEN
    jal copy_string_limited

    # Generate credits and grades with deterministic formulas.
    addu $t0, $s0, $s1
    li $t9, 4
    div $t0, $t9
    mfhi $t0
    sll $t7, $t0, 1
    addu $t0, $t0, $t7
    addiu $t0, $t0, 6
    la $t1, exam_credits
    sll $t2, $s3, 2
    addu $t1, $t1, $t2
    sw $t0, 0($t1)

    sll $t0, $s0, 1
    addu $t0, $t0, $s0
    sll $t1, $s1, 1
    addu $t0, $t0, $t1
    li $t9, 13
    div $t0, $t9
    mfhi $t0
    addiu $t0, $t0, 18
    la $t1, exam_grades
    sll $t2, $s3, 2
    addu $t1, $t1, $t2
    sw $t0, 0($t1)

    addiu $s1, $s1, 1
    j populate_exam_loop

populate_next_student:
    addiu $s0, $s0, 1
    j populate_student_loop

populate_done:
    li $t0, INITIAL_STUDENTS
    sw $t0, student_count
    li $v0, 4
    la $a0, msg_populated
    syscall

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addiu $sp, $sp, 20
    jr $ra

# Find a student ID among all allocated records, including inactive students.
# This prevents duplicate IDs after logical deletion until a slot is reused.
find_student_by_id_any:
    lw $t0, student_count
    li $t1, 0
# Scan all allocated slots, including inactive records, to detect
# duplicate IDs that are still stored after logical deletion.
find_any_loop:
    bge $t1, $t0, find_any_not_found
    sll $t2, $t1, 2
    la $t3, student_ids
    addu $t3, $t3, $t2
    lw $t4, 0($t3)
    beq $t4, $a0, find_any_found
    addiu $t1, $t1, 1
    j find_any_loop
find_any_found:
    move $v0, $t1
    jr $ra
find_any_not_found:
    li $v0, -1
    jr $ra

# Find a student ID among active records only.
# Student-specific menu operations use this lookup.
find_student_by_id_active:
    lw $t0, student_count
    li $t1, 0
# Accept only matching slots with active = 1 so menu operations
# cannot select a logically deleted student.
find_active_loop:
    bge $t1, $t0, find_active_not_found
    sll $t2, $t1, 2
    la $t3, student_active
    addu $t3, $t3, $t2
    lw $t4, 0($t3)
    beq $t4, $zero, find_active_next
    la $t3, student_ids
    addu $t3, $t3, $t2
    lw $t4, 0($t3)
    beq $t4, $a0, find_active_found
find_active_next:
    addiu $t1, $t1, 1
    j find_active_loop
find_active_found:
    move $v0, $t1
    jr $ra
find_active_not_found:
    li $v0, -1
    jr $ra

# Find an available student slot.
# Reuse an inactive slot first, otherwise return the next unused slot.
find_free_slot:
    lw $t0, student_count
    li $t1, 0
# Scan for an inactive slot within the allocated records, then
# check whether a new slot can be allocated at the end.
find_free_loop:
    bge $t1, $t0, find_free_after_used
    sll $t2, $t1, 2
    la $t3, student_active
    addu $t3, $t3, $t2
    lw $t4, 0($t3)
    beq $t4, $zero, find_free_found
    addiu $t1, $t1, 1
    j find_free_loop
find_free_after_used:
    li $t9, MAX_STUDENTS
    bge $t0, $t9, find_free_none
    move $v0, $t0
    jr $ra
find_free_found:
    move $v0, $t1
    jr $ra
find_free_none:
    li $v0, -1
    jr $ra

# Mandatory feature 1 - Insert a new student.
# Read and validate the ID, reject duplicates, find a slot, and store the student.
insert_student:
    addiu $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

insert_id_loop:
    la $a0, prompt_id
    li $a1, 1000000
    li $a2, 9999999
    jal read_int_prompt_range
    move $s1, $v0

    move $a0, $s1
    jal find_student_by_id_any
    li $t9, -1
    bne $v0, $t9, insert_duplicate

    jal find_free_slot
    move $s0, $v0
    li $t9, -1
    beq $s0, $t9, insert_full

    # Extend student_count when allocating the first previously unused slot.
    lw $t0, student_count
    bne $s0, $t0, insert_store_id
    addiu $t0, $t0, 1
    sw $t0, student_count

insert_store_id:
    sll $t0, $s0, 2
    la $t1, student_ids
    addu $t1, $t1, $t0
    sw $s1, 0($t1)

    la $a0, prompt_first
    la $a1, first_names
    sll $t2, $s0, 4
    sll $t3, $s0, 3
    addu $t2, $t2, $t3
    addu $a1, $a1, $t2
    li $a2, NAME_LEN
    jal read_string_prompt

    la $a0, prompt_last
    la $a1, last_names
    sll $t2, $s0, 4
    sll $t3, $s0, 3
    addu $t2, $t2, $t3
    addu $a1, $a1, $t2
    li $a2, NAME_LEN
    jal read_string_prompt

    la $a0, prompt_age
    li $a1, 16
    li $a2, 120
    jal read_int_prompt_range
    sll $t0, $s0, 2
    la $t1, student_ages
    addu $t1, $t1, $t0
    sw $v0, 0($t1)

    la $a0, prompt_year
    li $a1, 1900
    li $a2, CURRENT_YEAR
    jal read_int_prompt_range
    sll $t0, $s0, 2
    la $t1, student_years
    addu $t1, $t1, $t0
    sw $v0, 0($t1)

    sll $t0, $s0, 2
    la $t1, student_exam_counts
    addu $t1, $t1, $t0
    sw $zero, 0($t1)
    la $t1, student_active
    addu $t1, $t1, $t0
    li $t2, 1
    sw $t2, 0($t1)

    li $v0, 4
    la $a0, msg_inserted
    syscall
    j insert_done

insert_duplicate:
    li $v0, 4
    la $a0, msg_duplicate_id
    syscall
    j insert_id_loop

insert_full:
    li $v0, 4
    la $a0, msg_full_db
    syscall

insert_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addiu $sp, $sp, 12
    jr $ra

# Mandatory feature 2 - Print all students.
# Print active students using print_student_record for consistent formatting.
print_all_students:
    addiu $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    lw $s1, student_count
    beq $s1, $zero, print_all_empty
    li $s0, 0
# Scan all allocated slots, print active students, and count
# the records actually displayed.
print_all_loop:
    bge $s0, $s1, print_all_done
    sll $t0, $s0, 2
    la $t1, student_active
    addu $t1, $t1, $t0
    lw $t2, 0($t1)
    beq $t2, $zero, print_all_next
    move $a0, $s0
    jal print_student_record
print_all_next:
    addiu $s0, $s0, 1
    j print_all_loop

print_all_empty:
    li $v0, 4
    la $a0, msg_empty_db
    syscall

print_all_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addiu $sp, $sp, 12
    jr $ra

# Print student details, exam count, and weighted average.
print_student_record:
    addiu $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    move $s0, $a0

    li $v0, 4
    la $a0, label_id
    syscall
    sll $t0, $s0, 2
    la $t1, student_ids
    addu $t1, $t1, $t0
    lw $a0, 0($t1)
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, label_name
    syscall
    la $a0, first_names
    sll $t2, $s0, 4
    sll $t3, $s0, 3
    addu $t2, $t2, $t3
    addu $a0, $a0, $t2
    li $v0, 4
    syscall
    li $v0, 4
    la $a0, sep_space
    syscall
    la $a0, last_names
    sll $t2, $s0, 4
    sll $t3, $s0, 3
    addu $t2, $t2, $t3
    addu $a0, $a0, $t2
    li $v0, 4
    syscall

    li $v0, 4
    la $a0, label_age
    syscall
    sll $t0, $s0, 2
    la $t1, student_ages
    addu $t1, $t1, $t0
    lw $a0, 0($t1)
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, label_year
    syscall
    la $t1, student_years
    addu $t1, $t1, $t0
    lw $a0, 0($t1)
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, label_exams
    syscall
    la $t1, student_exam_counts
    addu $t1, $t1, $t0
    lw $a0, 0($t1)
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, label_avg
    syscall
    move $a0, $s0
    jal compute_weighted_average
    move $a0, $v0
    jal print_fixed_100

    li $v0, 4
    la $a0, sep_newline
    syscall

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addiu $sp, $sp, 8
    jr $ra

# Print a compact record for reports and best-student output.
print_compact_student:
    addiu $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    move $s0, $a0

    sll $t0, $s0, 2
    la $t1, student_ids
    addu $t1, $t1, $t0
    lw $a0, 0($t1)
    li $v0, 1
    syscall
    li $v0, 4
    la $a0, sep_dash
    syscall
    la $a0, first_names
    sll $t2, $s0, 4
    sll $t3, $s0, 3
    addu $t2, $t2, $t3
    addu $a0, $a0, $t2
    li $v0, 4
    syscall
    li $v0, 4
    la $a0, sep_space
    syscall
    la $a0, last_names
    sll $t2, $s0, 4
    sll $t3, $s0, 3
    addu $t2, $t2, $t3
    addu $a0, $a0, $t2
    li $v0, 4
    syscall
    li $v0, 4
    la $a0, label_avg
    syscall
    move $a0, $s0
    jal compute_weighted_average
    move $a0, $v0
    jal print_fixed_100
    li $v0, 4
    la $a0, sep_newline
    syscall

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addiu $sp, $sp, 8
    jr $ra

# Mandatory feature 3 - Search a student by ID.
search_by_id_action:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)

search_id_prompt_loop:
    la $a0, prompt_id_cancel
    li $a1, 0
    li $a2, 9999999
    jal read_int_prompt_range
    beq $v0, $zero, search_id_done
    move $a0, $v0
    jal find_student_by_id_active
    li $t9, -1
    beq $v0, $t9, search_id_not_found
    move $a0, $v0
    jal print_student_record
    j search_id_done

search_id_not_found:
    li $v0, 4
    la $a0, msg_not_found
    syscall
    j search_id_prompt_loop
search_id_done:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# Mandatory feature 4 - Search students by surname.
# Match the surname exactly and case-sensitively using strcmp.
search_by_surname_action:
    addiu $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)

    la $a0, prompt_last
    la $a1, input_buffer
    li $a2, 64
    jal read_string_prompt

    lw $s1, student_count
    li $s0, 0
    li $s2, 0
# Compare the requested surname against each active student
# and count the matching records.
search_surname_loop:
    bge $s0, $s1, search_surname_done_loop
    sll $t0, $s0, 2
    la $t1, student_active
    addu $t1, $t1, $t0
    lw $t2, 0($t1)
    beq $t2, $zero, search_surname_next

    la $a0, last_names
    sll $t3, $s0, 4
    sll $t4, $s0, 3
    addu $t3, $t3, $t4
    addu $a0, $a0, $t3
    la $a1, input_buffer
    jal strcmp
    bne $v0, $zero, search_surname_next

    move $a0, $s0
    jal print_student_record
    addiu $s2, $s2, 1

search_surname_next:
    addiu $s0, $s0, 1
    j search_surname_loop

search_surname_done_loop:
    bne $s2, $zero, search_surname_done
    li $v0, 4
    la $a0, msg_no_matches
    syscall
search_surname_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addiu $sp, $sp, 16
    jr $ra

# Mandatory feature 5 - Add a passed exam to a student.
# Require an active student, fewer than 20 exams, credits in 1..60, and a grade in 18..30.
add_exam_action:
    addiu $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)

add_exam_id_loop:
    la $a0, prompt_id_cancel
    li $a1, 0
    li $a2, 9999999
    jal read_int_prompt_range
    beq $v0, $zero, add_exam_done
    move $a0, $v0
    jal find_student_by_id_active
    li $t9, -1
    beq $v0, $t9, add_exam_not_found
    move $s0, $v0

    sll $t0, $s0, 2
    la $t1, student_exam_counts
    addu $t1, $t1, $t0
    lw $s1, 0($t1)
    li $t9, MAX_EXAMS
    bge $s1, $t9, add_exam_full

    # Locate the next available exam slot in the flattened arrays.
    sll $s2, $s0, 4
    sll $t9, $s0, 2
    addu $s2, $s2, $t9
    addu $s2, $s2, $s1

    la $a0, prompt_exam_name
    la $a1, exam_names
    sll $t2, $s2, 5
    addu $a1, $a1, $t2
    li $a2, EXAM_NAME_LEN
    jal read_string_prompt

    la $a0, prompt_credits
    li $a1, 1
    li $a2, MAX_CREDITS_INPUT
    jal read_int_prompt_range
    move $s3, $v0

    la $a0, prompt_grade
    li $a1, 18
    li $a2, 30
    jal read_int_prompt_range
    move $s4, $v0

    sll $t0, $s2, 2
    la $t1, exam_credits
    addu $t1, $t1, $t0
    sw $s3, 0($t1)
    la $t1, exam_grades
    addu $t1, $t1, $t0
    sw $s4, 0($t1)

    addiu $s1, $s1, 1
    sll $t0, $s0, 2
    la $t1, student_exam_counts
    addu $t1, $t1, $t0
    sw $s1, 0($t1)

    li $v0, 4
    la $a0, msg_added_exam
    syscall
    j add_exam_done

add_exam_not_found:
    li $v0, 4
    la $a0, msg_not_found
    syscall
    j add_exam_id_loop

add_exam_full:
    li $v0, 4
    la $a0, msg_exam_full
    syscall
    j add_exam_id_loop

add_exam_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addiu $sp, $sp, 24
    jr $ra

# Mandatory feature 6 - Edit student personal information.
# Keep the student ID unchanged while editing the other fields.
edit_student_action:
    addiu $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)

edit_id_loop:
    la $a0, prompt_id_cancel
    li $a1, 0
    li $a2, 9999999
    jal read_int_prompt_range
    beq $v0, $zero, edit_done
    move $a0, $v0
    jal find_student_by_id_active
    li $t9, -1
    beq $v0, $t9, edit_not_found
    move $s0, $v0

    la $a0, prompt_first
    la $a1, first_names
    sll $t2, $s0, 4
    sll $t3, $s0, 3
    addu $t2, $t2, $t3
    addu $a1, $a1, $t2
    li $a2, NAME_LEN
    jal read_string_prompt

    la $a0, prompt_last
    la $a1, last_names
    sll $t2, $s0, 4
    sll $t3, $s0, 3
    addu $t2, $t2, $t3
    addu $a1, $a1, $t2
    li $a2, NAME_LEN
    jal read_string_prompt

    la $a0, prompt_age
    li $a1, 16
    li $a2, 120
    jal read_int_prompt_range
    sll $t0, $s0, 2
    la $t1, student_ages
    addu $t1, $t1, $t0
    sw $v0, 0($t1)

    la $a0, prompt_year
    li $a1, 1900
    li $a2, CURRENT_YEAR
    jal read_int_prompt_range
    sll $t0, $s0, 2
    la $t1, student_years
    addu $t1, $t1, $t0
    sw $v0, 0($t1)

    li $v0, 4
    la $a0, msg_updated
    syscall
    j edit_done

edit_not_found:
    li $v0, 4
    la $a0, msg_not_found
    syscall
    j edit_id_loop
edit_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addiu $sp, $sp, 8
    jr $ra

# Mandatory feature 7 - Logical delete.
# Set student_active to 0 without physically erasing the record.
delete_student_action:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)

delete_id_loop:
    la $a0, prompt_id_cancel
    li $a1, 0
    li $a2, 9999999
    jal read_int_prompt_range
    beq $v0, $zero, delete_done
    move $a0, $v0
    jal find_student_by_id_active
    li $t9, -1
    beq $v0, $t9, delete_not_found

    sll $t0, $v0, 2
    la $t1, student_active
    addu $t1, $t1, $t0
    sw $zero, 0($t1)

    li $v0, 4
    la $a0, msg_deleted
    syscall
    j delete_done

delete_not_found:
    li $v0, 4
    la $a0, msg_not_found
    syscall
    j delete_id_loop
delete_done:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# ==========================================================
# SECTION D - ACADEMIC CALCULATIONS (AVERAGES AND CREDITS)
# ==========================================================
#    _   ___   _   ___  ___ __  __ ___ ___
#   /_\ / __| /_\ |   \| __|  \/  |_ _/ __|
#  / _ \ (__ / _ \| |) | _|| |\/| || | (__
# /_/ \_\___/_/ \_\___/|___|_|  |_|___\___|
# Compute the credit-weighted grade average.
# Formula: sum(grade * credits) / sum(credits).
# Return the truncated average scaled by 100, or -1 when no exams are available.
compute_weighted_average:
    addiu $sp, $sp, -12
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $ra, 8($sp)
    move $s0, $a0

    sll $t0, $s0, 2
    la $t1, student_exam_counts
    addu $t1, $t1, $t0
    lw $s1, 0($t1)
    beq $s1, $zero, compute_avg_none

    li $t2, 0
    li $t3, 0
    li $t4, 0
# Scan the student exams and accumulate sum(grade * credits)
# and sum(credits) for the fixed-point average.
compute_avg_loop:
    bge $t2, $s1, compute_avg_finish
    # global_exam_index = student_index * 20 + exam_index.
    sll $t5, $s0, 4
    sll $t7, $s0, 2
    addu $t5, $t5, $t7
    addu $t5, $t5, $t2
    sll $t6, $t5, 2

    la $t7, exam_credits
    addu $t7, $t7, $t6
    lw $t8, 0($t7)
    la $t7, exam_grades
    addu $t7, $t7, $t6
    lw $t9, 0($t7)

    # Accumulators: $t3 = sum(grade * credits), $t4 = sum(credits).
    mul $t9, $t9, $t8
    addu $t3, $t3, $t9
    addu $t4, $t4, $t8

    addiu $t2, $t2, 1
    j compute_avg_loop

compute_avg_finish:
    beq $t4, $zero, compute_avg_none
    # Scale by 100 before division to retain two decimal places.
    li $t0, 100
    mul $t3, $t3, $t0
    div $t3, $t4
    mflo $v0
    j compute_avg_done

compute_avg_none:
    li $v0, -1
compute_avg_done:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $ra, 8($sp)
    addiu $sp, $sp, 12
    jr $ra

# Compute the total credits earned by one student.
compute_total_credits:
    addiu $sp, $sp, -12
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $ra, 8($sp)
    move $s0, $a0

    sll $t0, $s0, 2
    la $t1, student_exam_counts
    addu $t1, $t1, $t0
    lw $s1, 0($t1)
    li $v0, 0
    li $t2, 0
# Visit each recorded exam and add its credits without
# changing the stored exam data.
total_credits_loop:
    bge $t2, $s1, total_credits_done
    sll $t3, $s0, 4
    sll $t6, $s0, 2
    addu $t3, $t3, $t6
    addu $t3, $t3, $t2
    sll $t3, $t3, 2
    la $t4, exam_credits
    addu $t4, $t4, $t3
    lw $t5, 0($t4)
    addu $v0, $v0, $t5
    addiu $t2, $t2, 1
    j total_credits_loop
total_credits_done:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $ra, 8($sp)
    addiu $sp, $sp, 12
    jr $ra

# Print an integer stored as the displayed value multiplied by 100.
# Example: 2444 is displayed as 24.44.
print_fixed_100:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    blt $a0, $zero, print_fixed_na

    li $t0, 100
    div $a0, $t0
    mflo $t1
    mfhi $t2

    move $a0, $t1
    li $v0, 1
    syscall
    li $v0, 4
    la $a0, sep_dot
    syscall
    li $t9, 10
    blt $t2, $t9, print_fixed_leading_zero
print_fixed_decimal:
    move $a0, $t2
    li $v0, 1
    syscall
    j print_fixed_done
print_fixed_leading_zero:
    li $a0, 0
    li $v0, 1
    syscall
    j print_fixed_decimal
print_fixed_na:
    li $v0, 4
    la $a0, not_available
    syscall
print_fixed_done:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# Mandatory feature 8 - Compute weighted average for one student.
average_action:
    addiu $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)

average_id_loop:
    la $a0, prompt_id_cancel
    li $a1, 0
    li $a2, 9999999
    jal read_int_prompt_range
    beq $v0, $zero, average_done
    move $a0, $v0
    jal find_student_by_id_active
    li $t9, -1
    beq $v0, $t9, average_not_found
    move $a0, $v0
    jal compute_weighted_average
    move $s0, $v0
    li $v0, 4
    la $a0, label_avg_plain
    syscall
    move $a0, $s0
    jal print_fixed_100
    li $v0, 4
    la $a0, sep_newline
    syscall
    j average_done

average_not_found:
    li $v0, 4
    la $a0, msg_not_found
    syscall
    j average_id_loop

average_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addiu $sp, $sp, 8
    jr $ra

# Mandatory feature 9 - Compute the best student by weighted average.
# Break ties by choosing the lower student ID.
best_student_action:
    addiu $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)

    lw $s1, student_count
    li $s0, 0
    li $s2, -1
    li $s3, -1
# Scan active students, compute each weighted average, and keep
# the best eligible candidate found so far.
best_loop:
    bge $s0, $s1, best_done_loop
    sll $t0, $s0, 2
    la $t1, student_active
    addu $t1, $t1, $t0
    lw $t2, 0($t1)
    beq $t2, $zero, best_next

    move $a0, $s0
    jal compute_weighted_average
    blt $v0, $zero, best_next
    bgt $v0, $s2, best_set
    bne $v0, $s2, best_next
    li $t9, -1
    beq $s3, $t9, best_set
    sll $t0, $s0, 2
    la $t1, student_ids
    addu $t1, $t1, $t0
    lw $t2, 0($t1)
    sll $t0, $s3, 2
    la $t1, student_ids
    addu $t1, $t1, $t0
    lw $t3, 0($t1)
    blt $t2, $t3, best_set
    j best_next
best_set:
    move $s2, $v0
    move $s3, $s0
best_next:
    addiu $s0, $s0, 1
    j best_loop

best_done_loop:
    li $t9, -1
    beq $s3, $t9, best_none
    li $v0, 4
    la $a0, label_best
    syscall
    move $a0, $s3
    jal print_compact_student
    j best_done

best_none:
    li $v0, 4
    la $a0, msg_no_best
    syscall

best_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addiu $sp, $sp, 20
    jr $ra

# Extra feature - Print the Top 5 students by weighted average.
# Use selected student indices to print the ranking without reordering records.
top_five_students_action:
    addiu $sp, $sp, -32
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    sw $s5, 24($sp)
    sw $s6, 28($sp)

    li $s4, 0
# Produce one ranking position per iteration, stopping after five
# students or when no eligible candidates remain.
top5_outer_loop:
    li $t9, TOP5_SIZE
    bge $s4, $t9, top5_done

    lw $s1, student_count
    li $s0, 0
    li $s2, -1
    li $s3, -1
# Find the best student who has not yet been selected, skipping
# inactive records and students without exams.
top5_scan_loop:
    bge $s0, $s1, top5_scan_done
    sll $t0, $s0, 2
    la $t1, student_active
    addu $t1, $t1, $t0
    lw $t2, 0($t1)
    beq $t2, $zero, top5_next_candidate

    li $s5, 0
# Compare the candidate index with previously selected indices
# to prevent a student from appearing twice in the ranking.
top5_selected_loop:
    bge $s5, $s4, top5_not_selected
    sll $t3, $s5, 2
    la $t4, top5_indices
    addu $t4, $t4, $t3
    lw $t5, 0($t4)
    beq $t5, $s0, top5_next_candidate
    addiu $s5, $s5, 1
    j top5_selected_loop

top5_not_selected:
    move $a0, $s0
    jal compute_weighted_average
    blt $v0, $zero, top5_next_candidate
    move $s6, $v0
    bgt $s6, $s2, top5_set_best
    bne $s6, $s2, top5_next_candidate

    sll $t0, $s0, 2
    la $t1, student_ids
    addu $t1, $t1, $t0
    lw $t2, 0($t1)
    sll $t0, $s3, 2
    la $t1, student_ids
    addu $t1, $t1, $t0
    lw $t3, 0($t1)
    blt $t2, $t3, top5_set_best
    j top5_next_candidate

top5_set_best:
    move $s2, $s6
    move $s3, $s0
top5_next_candidate:
    addiu $s0, $s0, 1
    j top5_scan_loop

top5_scan_done:
    li $t9, -1
    beq $s3, $t9, top5_no_more

    sll $t0, $s4, 2
    la $t1, top5_indices
    addu $t1, $t1, $t0
    sw $s3, 0($t1)

    addiu $a0, $s4, 1
    li $v0, 1
    syscall
    li $v0, 4
    la $a0, sep_dot
    syscall
    li $v0, 4
    la $a0, sep_space
    syscall
    move $a0, $s3
    jal print_compact_student

    addiu $s4, $s4, 1
    j top5_outer_loop

top5_no_more:
    bne $s4, $zero, top5_done
    li $v0, 4
    la $a0, msg_no_best
    syscall

top5_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    lw $s6, 28($sp)
    addiu $sp, $sp, 32
    jr $ra

# Mandatory feature 10 - Compute total credits for one student.
total_credits_action:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)

total_credits_id_loop:
    la $a0, prompt_id_cancel
    li $a1, 0
    li $a2, 9999999
    jal read_int_prompt_range
    beq $v0, $zero, total_credits_done_action
    move $a0, $v0
    jal find_student_by_id_active
    li $t9, -1
    beq $v0, $t9, total_credits_not_found

    move $a0, $v0
    jal compute_total_credits
    move $t0, $v0
    li $v0, 4
    la $a0, label_total_credits
    syscall
    move $a0, $t0
    li $v0, 1
    syscall
    li $v0, 4
    la $a0, sep_newline
    syscall
    j total_credits_done_action

total_credits_not_found:
    li $v0, 4
    la $a0, msg_not_found
    syscall
    j total_credits_id_loop
total_credits_done_action:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# Mandatory feature 11 - Print students above a given average threshold.
# Read an integer threshold and scale it by 100 for comparison.
above_threshold_action:
    addiu $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)

    la $a0, prompt_threshold
    li $a1, 0
    li $a2, 30
    jal read_int_prompt_range
    li $t9, 100
    mul $s2, $v0, $t9

    lw $s1, student_count
    li $s0, 0
    li $s3, 0
# Compute each active student average and print only records
# whose average is strictly above the requested threshold.
above_loop:
    bge $s0, $s1, above_done_loop
    sll $t0, $s0, 2
    la $t1, student_active
    addu $t1, $t1, $t0
    lw $t2, 0($t1)
    beq $t2, $zero, above_next
    move $a0, $s0
    jal compute_weighted_average
    ble $v0, $s2, above_next
    move $a0, $s0
    jal print_student_record
    addiu $s3, $s3, 1
above_next:
    addiu $s0, $s0, 1
    j above_loop
above_done_loop:
    bne $s3, $zero, above_done
    li $v0, 4
    la $a0, msg_no_matches
    syscall
above_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addiu $sp, $sp, 20
    jr $ra

# Mandatory feature 12 - Print students with at least N passed exams.
at_least_exams_action:
    addiu $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)

    la $a0, prompt_min_exams
    li $a1, 0
    li $a2, MAX_EXAMS
    jal read_int_prompt_range
    move $s2, $v0

    lw $s1, student_count
    li $s0, 0
    li $s3, 0
# Check each active student exam count and print records
# that meet or exceed the requested minimum.
at_least_loop:
    bge $s0, $s1, at_least_done_loop
    sll $t0, $s0, 2
    la $t1, student_active
    addu $t1, $t1, $t0
    lw $t2, 0($t1)
    beq $t2, $zero, at_least_next
    la $t1, student_exam_counts
    addu $t1, $t1, $t0
    lw $t2, 0($t1)
    blt $t2, $s2, at_least_next
    move $a0, $s0
    jal print_student_record
    addiu $s3, $s3, 1
at_least_next:
    addiu $s0, $s0, 1
    j at_least_loop
at_least_done_loop:
    bne $s3, $zero, at_least_done
    li $v0, 4
    la $a0, msg_no_matches
    syscall
at_least_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addiu $sp, $sp, 20
    jr $ra

# ==========================================================
# SECTION E - SORTING AND RECORD SWAPS
# ==========================================================
#  ___  ___  ___ _____ ___ _  _  ___
# / __|/ _ \| _ \_   _|_ _| \| |/ __|
# \__ \ (_) |   / | |  | || .` | (_ |
# |___/\___/|_|_\ |_| |___|_|\_|\___|
# Mandatory feature 13 - Sort students by ID.
# Bubble sort over allocated slots. Each swap moves all parallel record fields.
sort_by_id:
    addiu $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)

    lw $s2, student_count
    li $s0, 0
# Outer ID-sort loop: each pass places the largest remaining
# active ID, or an inactive record, at the end of the unsorted region.
sort_id_outer:
    addiu $t0, $s2, -1
    bge $s0, $t0, sort_id_done
    li $s1, 0
# Compare adjacent records and swap the entire student record
# when the pair is out of order.
sort_id_inner:
    subu $t0, $s2, $s0
    addiu $t0, $t0, -1
    bge $s1, $t0, sort_id_next_outer

    move $a0, $s1
    addiu $a1, $s1, 1
    jal should_swap_by_id
    beq $v0, $zero, sort_id_no_swap
    move $a0, $s1
    addiu $a1, $s1, 1
    jal swap_students
sort_id_no_swap:
    addiu $s1, $s1, 1
    j sort_id_inner
sort_id_next_outer:
    addiu $s0, $s0, 1
    j sort_id_outer
sort_id_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addiu $sp, $sp, 16
    jr $ra

should_swap_by_id:
    # Keep active students before inactive records.
    sll $t0, $a0, 2
    sll $t1, $a1, 2
    la $t2, student_active
    addu $t3, $t2, $t0
    lw $t4, 0($t3)
    addu $t3, $t2, $t1
    lw $t5, 0($t3)
    blt $t4, $t5, should_swap_yes
    bgt $t4, $t5, should_swap_no
    beq $t4, $zero, should_swap_no
    la $t2, student_ids
    addu $t3, $t2, $t0
    lw $t4, 0($t3)
    addu $t3, $t2, $t1
    lw $t5, 0($t3)
    bgt $t4, $t5, should_swap_yes
should_swap_no:
    move $v0, $zero
    jr $ra
should_swap_yes:
    li $v0, 1
    jr $ra

# Mandatory feature 14 - Sort students by weighted average.
# Sort by descending average, then ascending ID to break ties.
sort_by_average:
    addiu $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)

    lw $s2, student_count
    li $s0, 0
# Outer average-sort loop: shrink the unsorted region
# after each pass over adjacent records.
sort_avg_outer:
    addiu $t0, $s2, -1
    bge $s0, $t0, sort_avg_done
    li $s1, 0
# Decide whether adjacent slots must be swapped by comparing
# their weighted averages and using student IDs to break ties.
sort_avg_inner:
    subu $t0, $s2, $s0
    addiu $t0, $t0, -1
    bge $s1, $t0, sort_avg_next_outer

    move $a0, $s1
    addiu $a1, $s1, 1
    jal should_swap_by_average
    beq $v0, $zero, sort_avg_no_swap
    move $a0, $s1
    addiu $a1, $s1, 1
    jal swap_students
sort_avg_no_swap:
    addiu $s1, $s1, 1
    j sort_avg_inner
sort_avg_next_outer:
    addiu $s0, $s0, 1
    j sort_avg_outer
sort_avg_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addiu $sp, $sp, 16
    jr $ra

should_swap_by_average:
    addiu $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    move $s0, $a0
    move $s1, $a1

    # Active slots must precede inactive slots.
    sll $t0, $s0, 2
    sll $t1, $s1, 2
    la $t2, student_active
    addu $t3, $t2, $t0
    lw $t4, 0($t3)
    addu $t3, $t2, $t1
    lw $t5, 0($t3)
    blt $t4, $t5, should_swap_avg_yes
    bgt $t4, $t5, should_swap_avg_no
    beq $t4, $zero, should_swap_avg_no

    move $a0, $s0
    jal compute_weighted_average
    move $s2, $v0
    move $a0, $s1
    jal compute_weighted_average
    move $s3, $v0

    blt $s2, $s3, should_swap_avg_yes
    bgt $s2, $s3, should_swap_avg_no

    sll $t0, $s0, 2
    sll $t1, $s1, 2
    la $t2, student_ids
    addu $t3, $t2, $t0
    lw $t4, 0($t3)
    addu $t3, $t2, $t1
    lw $t5, 0($t3)
    bgt $t4, $t5, should_swap_avg_yes

should_swap_avg_no:
    move $v0, $zero
    j should_swap_avg_done
should_swap_avg_yes:
    li $v0, 1
should_swap_avg_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addiu $sp, $sp, 20
    jr $ra

# Swap complete student records, including numeric fields, names, and all exams.
swap_students:
    addiu $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    move $s0, $a0
    move $s1, $a1

    la $a0, student_ids
    move $a1, $s0
    move $a2, $s1
    jal swap_word_at
    la $a0, student_ages
    move $a1, $s0
    move $a2, $s1
    jal swap_word_at
    la $a0, student_years
    move $a1, $s0
    move $a2, $s1
    jal swap_word_at
    la $a0, student_exam_counts
    move $a1, $s0
    move $a2, $s1
    jal swap_word_at
    la $a0, student_active
    move $a1, $s0
    move $a2, $s1
    jal swap_word_at

    la $a0, first_names
    move $a1, $s0
    move $a2, $s1
    li $a3, STUDENT_NAME_BLOCK
    jal swap_byte_blocks
    la $a0, last_names
    move $a1, $s0
    move $a2, $s1
    li $a3, STUDENT_NAME_BLOCK
    jal swap_byte_blocks
    la $a0, exam_names
    move $a1, $s0
    move $a2, $s1
    li $a3, EXAM_TEXT_BLOCK
    jal swap_byte_blocks

    la $a0, exam_credits
    move $a1, $s0
    move $a2, $s1
    jal swap_exam_word_block
    la $a0, exam_grades
    move $a1, $s0
    move $a2, $s1
    jal swap_exam_word_block

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addiu $sp, $sp, 12
    jr $ra

# Swap two word-sized fields within the same array.
swap_word_at:
    sll $t0, $a1, 2
    sll $t1, $a2, 2
    addu $t2, $a0, $t0
    addu $t3, $a0, $t1
    lw $t4, 0($t2)
    lw $t5, 0($t3)
    sw $t5, 0($t2)
    sw $t4, 0($t3)
    jr $ra

# Swap two string blocks byte by byte. $a3 holds the block size.
swap_byte_blocks:
    mul $t0, $a1, $a3
    mul $t1, $a2, $a3
    addu $t2, $a0, $t0
    addu $t3, $a0, $t1
    li $t4, 0
# Exchange corresponding bytes in two blocks. Used for
# first names, surnames, and exam names.
swap_byte_loop:
    bge $t4, $a3, swap_byte_done
    lb $t5, 0($t2)
    lb $t6, 0($t3)
    sb $t6, 0($t2)
    sb $t5, 0($t3)
    addiu $t2, $t2, 1
    addiu $t3, $t3, 1
    addiu $t4, $t4, 1
    j swap_byte_loop
swap_byte_done:
    jr $ra

# Swap the 20 exam words belonging to each of two students.
swap_exam_word_block:
    sll $t0, $a1, 6
    sll $t7, $a1, 4
    addu $t0, $t0, $t7
    sll $t1, $a2, 6
    sll $t7, $a2, 4
    addu $t1, $t1, $t7
    addu $t2, $a0, $t0
    addu $t3, $a0, $t1
    li $t4, 0
# Exchange the 20 credit or grade values for two students
# while preserving the relationships between flattened exam arrays.
swap_exam_word_loop:
    li $t9, MAX_EXAMS
    bge $t4, $t9, swap_exam_word_done
    lw $t5, 0($t2)
    lw $t6, 0($t3)
    sw $t6, 0($t2)
    sw $t5, 0($t3)
    addiu $t2, $t2, 4
    addiu $t3, $t3, 4
    addiu $t4, $t4, 1
    j swap_exam_word_loop
swap_exam_word_done:
    jr $ra

# ==========================================================
# SECTION F - REPORTS AND STATISTICS
# ==========================================================
#  ___ ___ ___  ___  ___ _____
# | _ \ __| _ \/ _ \| _ \_   _|
# |   / _||  _/ (_) |   / | |
# |_|_\___|_|  \___/|_|_\ |_|
# Mandatory feature 15 - Print statistics.
# Compute statistics over active students:
# - Active student count.
# - Average age.
# - Average number of exams.
# - Mean of the scaled weighted averages of students with at least one exam.
print_statistics:
    addiu $sp, $sp, -32
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    sw $s5, 24($sp)
    sw $s6, 28($sp)

    li $v0, 4
    la $a0, msg_stats_title
    syscall

    lw $s1, student_count
    li $s0, 0
    li $s2, 0
    li $s3, 0
    li $s4, 0
    li $s5, 0
    li $s6, 0
# Visit each active student once and maintain separate
# accumulators for age, exam count, and weighted average.
stats_loop:
    bge $s0, $s1, stats_done_loop
    sll $t0, $s0, 2
    la $t1, student_active
    addu $t1, $t1, $t0
    lw $t2, 0($t1)
    beq $t2, $zero, stats_next

    # Accumulate the active student count, ages, and exam counts.
    addiu $s2, $s2, 1
    la $t1, student_ages
    addu $t1, $t1, $t0
    lw $t2, 0($t1)
    addu $s3, $s3, $t2
    la $t1, student_exam_counts
    addu $t1, $t1, $t0
    lw $t2, 0($t1)
    addu $s4, $s4, $t2

    move $a0, $s0
    jal compute_weighted_average
    blt $v0, $zero, stats_next
    # Include only available weighted averages from students with exams.
    addu $s5, $s5, $v0
    addiu $s6, $s6, 1

stats_next:
    addiu $s0, $s0, 1
    j stats_loop

stats_done_loop:
    li $v0, 4
    la $a0, label_total_active
    syscall
    move $a0, $s2
    li $v0, 1
    syscall
    li $v0, 4
    la $a0, sep_newline
    syscall

    li $v0, 4
    la $a0, label_avg_age
    syscall
    beq $s2, $zero, stats_age_na
    li $t9, 100
    mul $t0, $s3, $t9
    div $t0, $s2
    mflo $a0
    jal print_fixed_100
    j stats_age_done
stats_age_na:
    li $a0, -1
    jal print_fixed_100
stats_age_done:
    li $v0, 4
    la $a0, sep_newline
    syscall

    li $v0, 4
    la $a0, label_avg_exams
    syscall
    beq $s2, $zero, stats_exams_na
    li $t9, 100
    mul $t0, $s4, $t9
    div $t0, $s2
    mflo $a0
    jal print_fixed_100
    j stats_exams_done
stats_exams_na:
    li $a0, -1
    jal print_fixed_100
stats_exams_done:
    li $v0, 4
    la $a0, sep_newline
    syscall

    li $v0, 4
    la $a0, label_avg_grade
    syscall
    beq $s6, $zero, stats_grade_na
    div $s5, $s6
    mflo $a0
    jal print_fixed_100
    j stats_grade_done
stats_grade_na:
    li $a0, -1
    jal print_fixed_100
stats_grade_done:
    li $v0, 4
    la $a0, sep_newline
    syscall

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    lw $s6, 28($sp)
    addiu $sp, $sp, 32
    jr $ra

# Mandatory feature 16 - Export compact textual report to screen.
# Print the report directly to the MARS console without creating a file.
export_report:
    addiu $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    li $v0, 4
    la $a0, msg_report_title
    syscall
    li $v0, 4
    la $a0, label_slots
    syscall
    lw $a0, student_count
    li $v0, 1
    syscall
    li $v0, 4
    la $a0, sep_newline
    syscall

    jal print_statistics
    jal best_student_action

    lw $s1, student_count
    li $s0, 0
# After printing the summary statistics and best student, scan
# active records and print one compact row per student.
report_loop:
    bge $s0, $s1, report_done
    sll $t0, $s0, 2
    la $t1, student_active
    addu $t1, $t1, $t0
    lw $t2, 0($t1)
    beq $t2, $zero, report_next
    move $a0, $s0
    jal print_compact_student
report_next:
    addiu $s0, $s0, 1
    j report_loop
report_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addiu $sp, $sp, 12
    jr $ra

# ==========================================================
# SECTION G - RECURSIVE EXAM PRINTING
# ==========================================================
#  ___ ___ ___ _   _ ___  ___ ___ ___  _  _
# | _ \ __/ __| | | | _ \/ __|_ _/ _ \| \| |
# |   / _| (__| |_| |   /\__ \| | (_) | .` |
# |_|_\___\___|\___/|_|_\|___/___\___/|_|\_|
# Mandatory feature 17 - Recursive print of one student's exam list.
# Select the student, then delegate traversal to print_exams_recursive.
recursive_print_action:
    addiu $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)

recursive_id_loop:
    la $a0, prompt_id_cancel
    li $a1, 0
    li $a2, 9999999
    jal read_int_prompt_range
    beq $v0, $zero, recursive_done
    move $a0, $v0
    jal find_student_by_id_active
    li $t9, -1
    beq $v0, $t9, recursive_not_found
    move $s0, $v0

    move $a0, $s0
    jal print_student_record
    li $v0, 4
    la $a0, msg_exam_title
    syscall
    move $a0, $s0
    li $a1, 0
    jal print_exams_recursive
    j recursive_done

recursive_not_found:
    li $v0, 4
    la $a0, msg_not_found
    syscall
    j recursive_id_loop
recursive_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addiu $sp, $sp, 8
    jr $ra

# Recursive exam traversal.
# Arguments:
# $a0 = student index.
# $a1 = current exam index.
# Base case: exam_index >= student exam count.
# Recursive step: print the current exam, then recurse with index + 1.
# Each recursive call advances the exam index until the base case is reached.
print_exams_recursive:
    addiu $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    move $s0, $a0
    move $s1, $a1

    sll $t0, $s0, 2
    la $t1, student_exam_counts
    addu $t1, $t1, $t0
    lw $t2, 0($t1)
    beq $t2, $zero, print_exams_none_check
    bge $s1, $t2, print_exams_rec_done

    # Print the current exam before making the next recursive call.
    move $a0, $s0
    move $a1, $s1
    jal print_exam_record

    move $a0, $s0
    addiu $a1, $s1, 1
    jal print_exams_recursive
    j print_exams_rec_done

print_exams_none_check:
    bne $s1, $zero, print_exams_rec_done
    li $v0, 4
    la $a0, msg_no_exams
    syscall

print_exams_rec_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addiu $sp, $sp, 12
    jr $ra

# Print one exam row: position, name, credits, and grade.
print_exam_record:
    addiu $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    move $s0, $a0
    move $s1, $a1

    li $v0, 4
    la $a0, sep_open
    syscall
    addiu $a0, $s1, 1
    li $v0, 1
    syscall
    li $v0, 4
    la $a0, sep_close
    syscall

    sll $t0, $s0, 4
    sll $t7, $s0, 2
    addu $t0, $t0, $t7
    addu $t0, $t0, $s1
    la $a0, exam_names
    sll $t1, $t0, 5
    addu $a0, $a0, $t1
    li $v0, 4
    syscall

    li $v0, 4
    la $a0, sep_dash
    syscall
    li $v0, 4
    la $a0, label_credits
    syscall
    sll $t1, $t0, 2
    la $t2, exam_credits
    addu $t2, $t2, $t1
    lw $a0, 0($t2)
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, label_grade
    syscall
    la $t2, exam_grades
    addu $t2, $t2, $t1
    lw $a0, 0($t2)
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, sep_newline
    syscall

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addiu $sp, $sp, 12
    jr $ra
