# nametag
Command-line tool for working with (recipients of) DocuSign templates

#installing

    git clone git@github.com:liveoaktech/nametag.git
    bundle

#usage

    $ ./nametag help
    Commands:
      nametag delete FILE RECIPIENT_ID                                     # Remove a recipient without changing tabs
      nametag help [COMMAND]                                               # Describe available commands or one specific ...
      nametag list FILE                                                    # List all recipients in the template
      nametag reassign FILE --from=FROM_RECIPIENT_ID --to=TO_RECIPIENT_ID  # Reassign tabs from one recipient ID to another
      nametag rename FILE RECIPIENT_ID NEW_ROLE_NAME                       # Rename a recipient's role
      nametag xpath FILE SELECTOR                                          # Search template with xpath selector
