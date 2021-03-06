# Python 2 Directory Crawl
import os

file = "/"
pathway = "test.txt"

# def file_pathway(filename):
for root, dirs, files in os.walk(file, topdown=False):
    for f in files:
        try:
            current_file = os.path.join(root, f)
            final_path = str(os.path.join(current_file))
            print(final_path)
        except FileNotFoundError as e:
            # print("No such file or directory: ", e)
            with open("pyScript_errors.txt", "a") as errorFile:
                errorFile.write("Possible erroneous alias/shortcut: " + str(e) + "\n\n")
            continue
        except PermissionError as f:
            # print("Operation not permitted: ", f)
            with open("pyScript_errors.txt", "a") as errorFile:
                errorFile.write("Are you root?" + str(f) + "\n\n")
            continue
        except OSError as o:
            # print("Operation not permitted: ", o)
            with open("pyScript_errors.txt", "a") as errorFile:
                errorFile.write("Check this out: " + str(o) + "\n\n")
            continue
