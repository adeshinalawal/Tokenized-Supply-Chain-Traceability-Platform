;; Event Tracking Contract
;; Monitors supply chain milestones

(define-map events
  { event-id: (string-ascii 36) }
  {
    product-id: (string-ascii 36),
    entity-id: (string-ascii 36),
    event-type: uint,
    location: (optional (string-utf8 100)),
    timestamp: uint,
    data: (optional (string-utf8 500))
  }
)

;; Event types: 1=Production, 2=Packaging, 3=Shipping, 4=Receiving, 5=Quality Check
(define-read-only (get-event (event-id (string-ascii 36)))
  (map-get? events { event-id: event-id })
)

(define-read-only (get-product-events (product-id (string-ascii 36)))
  ;; In a real implementation, we would have a way to query all events for a product
  ;; For simplicity, this is not implemented here
  (ok true)
)

(define-public (record-event
    (event-id (string-ascii 36))
    (product-id (string-ascii 36))
    (entity-id (string-ascii 36))
    (event-type uint)
    (location (optional (string-utf8 100)))
    (data (optional (string-utf8 500)))
  )
  (let
    ((timestamp (get-block-info? time (- block-height u1))))
    (asserts! (is-some timestamp) (err u3000))
    (asserts! (and (>= event-type u1) (<= event-type u5)) (err u3001))
    (asserts! (is-none (get-event event-id)) (err u3002))

    ;; In production, verify that product exists and entity is verified

    (ok (map-set events
      { event-id: event-id }
      {
        product-id: product-id,
        entity-id: entity-id,
        event-type: event-type,
        location: location,
        timestamp: (unwrap-panic timestamp),
        data: data
      }
    ))
  )
)
