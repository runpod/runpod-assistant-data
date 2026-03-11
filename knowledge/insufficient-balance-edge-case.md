# Insufficient Balance When Purchasing Savings Plans

## Problem

Users may see an "insufficient balance" error when trying to purchase a savings plan (such as a 3-month or 6-month A40 Pod savings plan), even when their account balance appears to match the displayed plan price exactly.

**Example scenario:** A user adds $876.00 to their account and tries to deploy an A40 Pod under a 6-month savings plan that shows a total price of $876.00. Despite the balance matching the displayed price, the system reports "insufficient balance."

## Why This Happens

Even a difference of just a few cents can prevent the purchase from going through. The account balance cannot be exactly equal to the plan price because users must also cover:

1. **Storage costs** - Pod storage incurs additional charges beyond the base plan price. The savings plan only covers GPU compute, not storage, so users need extra balance to cover their storage allocation.
2. **Per-hour rounding** - Minor rounding in per-hour billing calculations can create small overages
3. **Safety margin** - The system requires a small buffer to ensure the plan can be fulfilled without interruption

Users need to add a small amount extra beyond the displayed plan price (typically $10-20 depending on the plan size and storage needs).

## Important Clarification

The most common causes are the storage buffer and billing rounding described above. However, **taxes may also contribute** for users in taxed jurisdictions — Runpod does collect sales tax in applicable regions, which is added on top of the displayed plan price. If a user is in a taxed jurisdiction, the effective total will be higher than the listed price. In most cases the shortfall is due to the storage/rounding buffer, but do not rule out taxes as a contributing factor.

## Solution

To resolve this issue, users should:

1. Add a small additional amount to their account balance (recommend $10-20 extra beyond the plan price)
2. Retry the savings plan purchase

## Example Response

If a user asks why they see "insufficient balance" when their balance matches the plan price:

> The system requires a small buffer beyond the displayed plan price to account for potential storage costs and minor billing rounding. If you're in a taxed jurisdiction, sales tax is also added on top of the listed price. I recommend adding an extra $10-20 to your account balance and trying again.
