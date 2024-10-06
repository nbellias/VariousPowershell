# First: Install-Module -Name ImportExcel -Force -Scope CurrentUser

# Import necessary modules
Import-Module ImportExcel
Import-Module ./RandomDateOfBirth.psm1

# Read first names and last names from Excel files
$firstNames = Import-Excel -Path "Data\first_names_list.xlsx"
$lastNames = Import-Excel -Path "Data\last_names_list.xlsx"

# Convert the first and last names to arrays
$firstNameList = $firstNames | Select-Object -ExpandProperty FirstName  # Adjust the column name
$lastNameList = $lastNames | Select-Object -ExpandProperty LastName     # Adjust the column name

# Initialize empty array for storing the result
$randomDataList = @()

# Get the count of names (use the minimum count to avoid index out of bounds)
$count = [math]::Min($firstNameList.Count, $lastNameList.Count)

# Loop to create random list
for ($i = 0; $i -lt $count; $i++) {
    $uuid = [guid]::NewGuid().ToString()
    
    # Get random first name and last name from the lists
    $randomFirstName = $firstNameList | Get-Random
    $randomLastName = $lastNameList | Get-Random

    # Generate a random date of birth
    $dateOfBirth = Get-RandomDateOfBirth

    # Add generated data to the list
    $randomDataList += [PSCustomObject]@{
        ID          = $uuid
        FirstName   = $randomFirstName
        LastName    = $randomLastName
        DateOfBirth = $dateOfBirth
    }
}

# Export the result to a new Excel file
$randomDataList | Export-Excel -Path "random_persons_list.xlsx" -AutoSize