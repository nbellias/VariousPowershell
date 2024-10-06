function Get-RandomDateOfBirth {
    $startDate = Get-Date -Year 1980 -Month 1 -Day 1
    $endDate = Get-Date -Year 2010 -Month 1 -Day 1
    $daysDifference = ($endDate - $startDate).Days
    $randomDays = Get-Random -Minimum 0 -Maximum $daysDifference
    $randomDate = $startDate.AddDays($randomDays)
    
    # Return only the date part
    return $randomDate.ToString("yyyy-MM-dd")
}