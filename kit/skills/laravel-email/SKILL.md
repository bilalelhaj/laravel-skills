---
name: laravel-email
description: Opinionated guide for sending email in Laravel — Mailables vs Notifications, queueing, Markdown, testing. Use when building any email/notification feature in a Laravel app.
---

# Sending email in Laravel (opinionated)

## Pick the right tool
- **Notification** — an event the user is told about, possibly over multiple channels
  (mail + database + Slack). Default for "user did X, tell someone". `php artisan make:notification`.
- **Mailable** — a specific email document with its own template/content. Use when it's
  purely email and content-heavy. `php artisan make:mail OrderShipped --markdown=mail.orders.shipped`.
- Don't build both for the same thing. Notification with a `toMail()` covers most cases.

## Rules
- **Always queue.** Implement `ShouldQueue` on Mailables/Notifications. Sending mail inline
  blocks the request and couples it to SMTP uptime. Exception only for a CLI one-off.
- **Markdown mail** for anything templated — themeable, responsive, less HTML to maintain.
- **No business logic in the Mailable.** Pass a built DTO/model in; the Mailable only shapes output.
- **Addresses/subjects from config or the model**, never hardcoded. Sender via `config('mail.from')`.
- **Localize** subject + body if the app is multi-locale (`->locale($user->locale)`).
- Respect user preferences / unsubscribe before dispatch — that's a domain check, do it in the Action.

## Shape
```php
// In an Action, not a controller:
$user->notify(new OrderShipped($order));         // queued, multi-channel
// or
Mail::to($user)->queue(new InvoicePaid($invoice)); // queued mailable
```

```php
final class OrderShipped extends Notification implements ShouldQueue
{
    use Queueable;
    public function __construct(private readonly Order $order) {}
    public function via(object $notifiable): array { return ['mail', 'database']; }
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject(__('mail.order_shipped.subject', ['id' => $this->order->id]))
            ->markdown('mail.orders.shipped', ['order' => $this->order]);
    }
}
```

## Testing (required)
- `Mail::fake()` / `Notification::fake()` in the test, dispatch, then
  `Mail::assertQueued(...)` / `Notification::assertSentTo($user, OrderShipped::class)`.
- Assert the recipient, the mailable/notification class, and key content — not the rendered HTML byte-for-byte.
- Use `MAIL_MAILER=array` or `log` in `.env.testing`; never hit a real SMTP in tests.

## Local + prod
- Dev: Mailpit (`MAIL_MAILER=smtp`, host `mailpit`). Prod: a real transactional provider
  (Postmark/SES/Resend) configured purely via env — swap mailer without code changes.
- Make sure a queue worker runs (`php artisan queue:work`) or mail never leaves.
