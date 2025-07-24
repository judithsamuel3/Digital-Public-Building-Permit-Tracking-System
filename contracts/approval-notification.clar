;; Approval Notification Contract
;; Sends permit approvals and construction authorization

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-INPUT (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-INVALID-STATUS (err u104))
(define-constant ERR-EXPIRED (err u106))

;; Data Variables
(define-data-var next-permit-id uint u1)
(define-data-var default-permit-duration uint u5256000) ;; ~1 year in blocks

;; Data Maps
(define-map permits
  { permit-id: uint }
  {
    application-id: uint,
    applicant: principal,
    permit-type: (string-ascii 50),
    status: (string-ascii 20),
    issued-at: uint,
    expires-at: uint,
    conditions: (string-ascii 500),
    authorized-work: (string-ascii 300)
  }
)

(define-map application-permits
  { application-id: uint }
  { permit-id: uint }
)

(define-map notifications
  { notification-id: uint }
  {
    recipient: principal,
    message-type: (string-ascii 30),
    subject: (string-ascii 100),
    message: (string-ascii 500),
    sent-at: uint,
    read: bool
  }
)

(define-map user-notifications
  { user: principal }
  { notification-ids: (list 50 uint) }
)

(define-data-var next-notification-id uint u1)

;; Permit Management Functions
(define-public (issue-permit
  (application-id uint)
  (applicant principal)
  (permit-type (string-ascii 50))
  (conditions (string-ascii 500))
  (authorized-work (string-ascii 300)))
  (let
    (
      (permit-id (var-get next-permit-id))
      (current-block block-height)
      (expiry-block (+ current-block (var-get default-permit-duration)))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> (len permit-type) u0) ERR-INVALID-INPUT)
    (asserts! (> (len authorized-work) u0) ERR-INVALID-INPUT)

    (map-set permits
      { permit-id: permit-id }
      {
        application-id: application-id,
        applicant: applicant,
        permit-type: permit-type,
        status: "active",
        issued-at: current-block,
        expires-at: expiry-block,
        conditions: conditions,
        authorized-work: authorized-work
      }
    )

    (map-set application-permits
      { application-id: application-id }
      { permit-id: permit-id }
    )

    (var-set next-permit-id (+ permit-id u1))

    ;; Send approval notification
    (unwrap! (send-notification
      applicant
      "permit-approval"
      "Building Permit Approved"
      "Your building permit has been approved and issued.") ERR-INVALID-INPUT)

    (ok permit-id)
  )
)

(define-public (revoke-permit (permit-id uint) (reason (string-ascii 200)))
  (let
    (
      (permit (unwrap! (map-get? permits { permit-id: permit-id }) ERR-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status permit) "active") ERR-INVALID-STATUS)

    (map-set permits
      { permit-id: permit-id }
      (merge permit { status: "revoked" })
    )

    ;; Send revocation notification
    (unwrap! (send-notification
      (get applicant permit)
      "permit-revocation"
      "Building Permit Revoked"
      reason) ERR-INVALID-INPUT)

    (ok true)
  )
)

(define-public (extend-permit (permit-id uint) (additional-blocks uint))
  (let
    (
      (permit (unwrap! (map-get? permits { permit-id: permit-id }) ERR-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status permit) "active") ERR-INVALID-STATUS)
    (asserts! (> additional-blocks u0) ERR-INVALID-INPUT)

    (map-set permits
      { permit-id: permit-id }
      (merge permit { expires-at: (+ (get expires-at permit) additional-blocks) })
    )

    ;; Send extension notification
    (unwrap! (send-notification
      (get applicant permit)
      "permit-extension"
      "Building Permit Extended"
      "Your building permit has been extended.") ERR-INVALID-INPUT)

    (ok true)
  )
)

;; Notification Functions
(define-public (send-notification
  (recipient principal)
  (message-type (string-ascii 30))
  (subject (string-ascii 100))
  (message (string-ascii 500)))
  (let
    (
      (notification-id (var-get next-notification-id))
      (current-notifications (default-to { notification-ids: (list) }
        (map-get? user-notifications { user: recipient })))
    )
    (asserts! (> (len message-type) u0) ERR-INVALID-INPUT)
    (asserts! (> (len subject) u0) ERR-INVALID-INPUT)
    (asserts! (> (len message) u0) ERR-INVALID-INPUT)

    (map-set notifications
      { notification-id: notification-id }
      {
        recipient: recipient,
        message-type: message-type,
        subject: subject,
        message: message,
        sent-at: block-height,
        read: false
      }
    )

    (map-set user-notifications
      { user: recipient }
      { notification-ids: (unwrap! (as-max-len?
        (append (get notification-ids current-notifications) notification-id) u50) ERR-INVALID-INPUT) }
    )

    (var-set next-notification-id (+ notification-id u1))
    (ok notification-id)
  )
)

(define-public (mark-notification-read (notification-id uint))
  (let
    (
      (notification (unwrap! (map-get? notifications { notification-id: notification-id }) ERR-NOT-FOUND))
    )
    (asserts! (is-eq (get recipient notification) tx-sender) ERR-NOT-AUTHORIZED)

    (ok (map-set notifications
      { notification-id: notification-id }
      (merge notification { read: true })
    ))
  )
)

;; Read-only Functions
(define-read-only (get-permit (permit-id uint))
  (map-get? permits { permit-id: permit-id })
)

(define-read-only (get-application-permit (application-id uint))
  (map-get? application-permits { application-id: application-id })
)

(define-read-only (is-permit-valid (permit-id uint))
  (match (map-get? permits { permit-id: permit-id })
    permit (and (is-eq (get status permit) "active")
                (> (get expires-at permit) block-height))
    false)
)

(define-read-only (get-notification (notification-id uint))
  (map-get? notifications { notification-id: notification-id })
)

(define-read-only (get-user-notifications (user principal))
  (map-get? user-notifications { user: user })
)

(define-read-only (get-unread-notifications-count (user principal))
  (match (map-get? user-notifications { user: user })
    user-notifs (count-unread-notifications (get notification-ids user-notifs))
    u0)
)

(define-read-only (get-permit-duration)
  (var-get default-permit-duration)
)

;; Helper Functions
(define-private (count-unread-notifications (notification-ids (list 50 uint)))
  (fold count-unread notification-ids u0)
)

(define-private (count-unread (notification-id uint) (count uint))
  (match (map-get? notifications { notification-id: notification-id })
    notification (if (get read notification) count (+ count u1))
    count)
)

;; Administrative Functions
(define-public (set-permit-duration (new-duration uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> new-duration u0) ERR-INVALID-INPUT)
    (ok (var-set default-permit-duration new-duration))
  )
)
