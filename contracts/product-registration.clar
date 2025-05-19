;; Product Registration Contract
;; Records item details and specifications

(define-map products
  { product-id: (string-ascii 36) }
  {
    entity-id: (string-ascii 36),
    name: (string-utf8 100),
    description: (string-utf8 500),
    metadata-url: (optional (string-utf8 256)),
    registration-time: uint
  }
)

(define-read-only (get-product (product-id (string-ascii 36)))
  (map-get? products { product-id: product-id })
)

(define-public (register-product
    (product-id (string-ascii 36))
    (entity-id (string-ascii 36))
    (name (string-utf8 100))
    (description (string-utf8 500))
    (metadata-url (optional (string-utf8 256)))
  )
  (let
    ((registration-time (get-block-info? time (- block-height u1))))
    (asserts! (is-some registration-time) (err u2000))
    (asserts! (is-none (get-product product-id)) (err u2001))

    ;; Check if entity exists and is verified (would call entity-verification contract in production)
    ;; For simplicity, we're not implementing contract calls here

    (ok (map-set products
      { product-id: product-id }
      {
        entity-id: entity-id,
        name: name,
        description: description,
        metadata-url: metadata-url,
        registration-time: (unwrap-panic registration-time)
      }
    ))
  )
)

(define-public (update-product-metadata
    (product-id (string-ascii 36))
    (metadata-url (optional (string-utf8 256)))
  )
  (match (map-get? products { product-id: product-id })
    product (begin
      ;; In production, verify that tx-sender is the entity that registered the product
      (ok (map-set products
        { product-id: product-id }
        (merge product { metadata-url: metadata-url })
      ))
    )
    (err u2002)
  )
)
