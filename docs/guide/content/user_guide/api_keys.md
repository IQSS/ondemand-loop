# API keys

Some repository features in OnDemand Loop require access to restricted content. API keys let the application request this content — such as draft datasets or unpublished depositions — from services like Dataverse and Zenodo on your behalf.

 Without a repository API key, OnDemand Loop can browse and download only the public versions of datasets that have already been published. Drafts or private uploads remain inaccessible, and attempts to load them from the interface will fail.

---

### Getting your Dataverse API token

1. Sign in to your Dataverse installation.
2. Click your user name in the top-right corner and select **API Token** from the menu.
3. If you do not already have a token, click **Create Token**. Otherwise, copy the existing token value.
4. If you already have a token, check the expiration date. If it has expired, click **Recreate Token** to obtain a new one.
5. Keep the token secure — treat it like a password. You can regenerate or delete it at any time from the same page.

---

### Getting your Zenodo API key

1. Sign in to Zenodo. 
2. Open the **Applications** page from the user menu.
3. In the **Personal access tokens** section, click **New token**.
4. Enter a descriptive name (for example, `OnDemand Loop`) and select the scopes required by your workflow. For accessing drafts and uploading files through OnDemand Loop, enable at least the `deposit:actions` and `deposit:write` scopes.
5. Click **Create** and copy the generated token. This value is shown only once; store it securely.

!!! warning

    Zenodo lets you create multiple tokens with different permissions. Remove any tokens you no longer use to reduce risk if a key is ever exposed.

---

### Setting API keys in OnDemand Loop

Once you have the token or key, add it to the corresponding repository connector:

#### The repository exists in Settings

1. In OnDemand Loop, open the **Repositories** drop-down in the navigation bar and choose **Settings**.
2. Select the repository installation you want to configure (It has been used previously).
3. Paste your API token in the field provided for that connector.
4. Click on **Save Changes** to store the credentials securely for the current user account.

#### The repository does not exist in Settings

1. In OnDemand Loop, open the **Repositories** drop-down in the navigation bar and choose **Settings**.
2. If the repository has not been configured, click on **Add repository** and enter the repository url (for example
   https://demo.dataverse.org).
3. Select the repository installation yu have just created.
4. Paste your API token in the field provided for that connector.
5. Click on **Save Changes** to store the credentials securely for the current user account.


After you save the key, OnDemand Loop can load draft datasets from Dataverse, view unpublished Zenodo depositions, and perform other actions that require authenticated access. You can remove or update keys at any time from the same settings page.
