# PURPOSE: Demonstrates how to efficiently write a large file 
# with $numOfPersons random persons rows using PowerShell collections
#and parallel jobs.

Import-Module ImportExcel

$machineCores = (Get-CimInstance -ClassName Win32_Processor).NumberOfCores

# Define the file path
$filePath = "MyPersons.txt"

# Number of persons to generate
$numOfPersons = 10000

# Create a log entry with the current date and time
$startTime = Get-Date
$timeS = $startTime.ToString("yyyy-MM-dd HH:mm:ss")
Write-Host "Starting at $timeS" -ForegroundColor Green

# Generate the persons
# Read first names and last names from Excel files
$firstNames = Import-Excel -Path "Data\first_names_list.xlsx"
$lastNames = Import-Excel -Path "Data\last_names_list.xlsx"

# Convert the first and last names to arrays
$firstNameList = $firstNames | Select-Object -ExpandProperty FirstName  # Adjust the column name
$lastNameList = $lastNames | Select-Object -ExpandProperty LastName     # Adjust the column name

# # Pre-allocate a memory array
# $persons = New-Object System.Collections.Generic.List[string] $numOfPersons

# for ($i = 0; $i -lt $numOfPersons; $i++) {
#     $uuid = [guid]::NewGuid().ToString()
    
#     # Get random first name and last name from the lists
#     $randomFirstName = $firstNameList | Get-Random
#     $randomLastName = $lastNameList | Get-Random

#     # Generate a random date of birth
#     $dateOfBirth = Get-RandomDateOfBirth

#     $persons.Add("$uuid,$randomFirstName,$randomLastName,$dateOfBirth")
# }

# # Write all persons to the file in one operation
# $persons | Out-File -FilePath $filePath -Encoding ASCII

$jobs = @()
$chunkSize = [math]::Ceiling($numOfPersons / $machineCores)

# Create parallel background jobs
for ($jobIndex = 0; $jobIndex -lt $machineCores; $jobIndex++) {
    $jobs += Start-Job -ScriptBlock {
        Param ($startIndex, $chunkSize, $firstNameList, $lastNameList)

        Import-Module ./RandomDateOfBirth.psm1 # This is needed to import the function in the job
        # Generate a chunk of persons in this job
        $personsChunk = New-Object System.Collections.Generic.List[string] $chunkSize
        for ($i = $startIndex; $i -lt ($startIndex + $chunkSize); $i++) {
            $uuid = [guid]::NewGuid().ToString()

            # Get random first name and last name from the lists
            $randomFirstName = $firstNameList | Get-Random
            $randomLastName = $lastNameList | Get-Random

            # Generate a random date of birth using the function defined above
            $dateOfBirth = Get-RandomDateOfBirth

            # Add the person details to the list
            $personsChunk.Add("$uuid,$randomFirstName,$randomLastName,$dateOfBirth")
        }

        # Return the chunk of generated persons
        return $personsChunk
    } -ArgumentList ([int]($jobIndex * $chunkSize), [int]$chunkSize, $firstNameList, $lastNameList)
}

# Wait for all jobs to finish and collect results
$results = $jobs | Receive-Job -Wait -AutoRemoveJob

# Combine all job results into a single list
$allPersons = New-Object System.Collections.Generic.List[string]
foreach ($result in $results) {
    $allPersons.Add($result)
}

# Write all persons to the file in one operation
$allPersons | Out-File -FilePath $filePath -Encoding ASCII

# Create a log entry with the current date and time
$finishTime = Get-Date
$timeF = $finishTime.ToString("yyyy-MM-dd HH:mm:ss")
Write-Host "Finishing at $timeF" -ForegroundColor Red
Write-Host "Elapsed time: $(($finishTime - $startTime).TotalSeconds) seconds"

# Print completion message
Write-Host "File with $numOfPersons persons created successfully at $filePath"
