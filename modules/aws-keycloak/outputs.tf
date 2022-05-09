#  "KeyCloakDatabaseDBSecretArn28BEB641": {
#       "Value": {
#         "Ref": "KeyCloakDatabaseDBClusterSecretAttachment50401C92"
#       }
#     },
#     "KeyCloakDatabaseclusterEndpointHostname38FB0D1E": {
#       "Value": {
#         "Fn::GetAtt": [
#           "KeyCloakDatabaseDBCluster06E9C0E1",
#           "Endpoint.Address"
#         ]
#       }
#     },
#     "KeyCloakDatabaseclusterIdentifierF00C290B": {
#       "Value": {
#         "Ref": "KeyCloakDatabaseDBCluster06E9C0E1"
#       }
#     },
#     "KeyCloakKeyCloakContainerSerivceEndpointURL9C81E19A": {
#       "Value": {
#         "Fn::Join": [
#           "",
#           [
#             "https://",
#             {
#               "Fn::GetAtt": [
#                 "KeyCloakKeyCloakContainerSerivceALBE100B67D",
#                 "DNSName"
#               ]
#             }
#           ]
#         ]
#       }
#     }
#   },