# Gold Loan Manager

## GitHub Pages deployment

1. Create a **Public** GitHub repository named `gold-loan-manager`.
2. Upload `index.html` to the repository root and commit it.
3. Open **Settings → Pages**.
4. Under **Build and deployment**, choose **Deploy from a branch**.
5. Select branch `main` and folder `/(root)`, then Save.
6. Wait for GitHub Pages to publish. The URL will be:
   `https://YOUR-GITHUB-USERNAME.github.io/gold-loan-manager/`

## Supabase setup

1. Open your Supabase project → SQL Editor.
2. Open `supabase_setup.sql`, copy all SQL, and run it.
3. Open the published site and sign in / create your app account.
4. Use the same account on your phone and tablet.

## Important

- Do not upload Supabase `service_role` or secret keys to GitHub.
- The browser app uses the Supabase publishable key and relies on Row Level Security.
- Receipt image upload requires the private `gold-loan-receipts` Storage bucket and policies created by the SQL file.
- OCR reads receipt images as a suggestion. Verify the date, amount and interest against the original receipt before saving.
- GitHub Pages is static hosting; Supabase provides authentication and cloud data storage.
