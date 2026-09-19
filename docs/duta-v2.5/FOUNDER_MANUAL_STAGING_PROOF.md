# Founder Manual Staging Proof — Google OAuth

This checklist is required only because the Google authorization ceremony is interactive and must be completed by the account holder. Do not provide a password, OTP, token, cookie, or URL in chat.

1. Open the authorized staging Preview application.
2. Select **Continue with Google**.
3. Complete Google consent in the browser.
4. Confirm return to DUTA as a signed-in Member: report only `PASS` or `FAIL`.
5. Open **Saya** and confirm the displayed name is your authenticated account, not a preview identity: report `PASS` or `FAIL`.
6. Reload once and confirm the signed-in state remains: report `PASS` or `FAIL`.
7. Select logout, reload, then open **Saya**: confirm access redirects to **Masuk**: report `PASS` or `FAIL`.

Optional only if the Community join control is visibly present and backed by a designated staging test Community: join, reload, leave, reload; report each `PASS` or `FAIL`. Do not create public-like data and do not share its name, ID, or any private data here.
