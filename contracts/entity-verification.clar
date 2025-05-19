;; Entity Verification Contract
;; Validates supply chain participants

(define-data-var admin principal tx-sender)

;; Entity types: 1=Manufacturer, 2=Distributor, 3=Retailer, 4=Certifier
(define-map entities
  { entity-id: (string-ascii 36) }
  {
    owner: principal,
    name: (string-utf8 100),
    entity-type: uint,
    verified: bool,
    registration-time: uint
  }
)

(define-read-only (get-entity (entity-id (string-ascii 36)))
  (map-get? entities { entity-id: entity-id })
)

(define-public (register-entity
    (entity-id (string-ascii 36))
    (name (string-utf8 100))
    (entity-type uint)
  )
  (let
    ((registration-time (get-block-info? time (- block-height u1))))
    (asserts! (is-some registration-time) (err u1000))
    (asserts! (and (>= entity-type u1) (<= entity-type u4)) (err u1001))
    (asserts! (is-none (get-entity entity-id)) (err u1002))

    (ok (map-set entities
      { entity-id: entity-id }
      {
        owner: tx-sender,
        name: name,
        entity-type: entity-type,
        verified: false,
        registration-time: (unwrap-panic registration-time)
      }
    ))
  )
)

(define-public (verify-entity (entity-id (string-ascii 36)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1003))
    (match (map-get? entities { entity-id: entity-id })
      entity (ok (map-set entities
                  { entity-id: entity-id }
                  (merge entity { verified: true })
                ))
      (err u1004)
    )
  )
)

(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1003))
    (ok (var-set admin new-admin))
  )
)
