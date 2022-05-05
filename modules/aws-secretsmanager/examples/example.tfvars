secrets = {
  shared = {
    accounts = [
      "accountid-1", # Test
      "accountid-2", # Prod
    ]
    keys = [
      "service-1/api-key",
    ]
  }
  prod = {
    accounts = [
      "accountid-2" # Prod
    ]
    keys = [
      "cluster-1/component-1/private-key"
    ]
  }
}