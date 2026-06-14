-- models/Silver/silver_sales.sql

with sales as (
    -- bronze model, already cleaned
    select
        sales_id,
        store_sk,
        customer_sk,
        quantity,
        unit_price,
        {{ multiply('quantity', 'unit_price') }} as total_amount
    from {{ ref('bronze_sales') }}       -- ← ref() not raw table
),

stores as (
    -- filter/clean store data independently
    select
        store_sk,
        store_name,
        region
    from {{ ref('bronze_store') }}
    where store_name is not null         -- ← clean here, isolated
),

customers as (
    -- filter/clean customer data independently
    select
        customer_sk,
        first_name
    from {{ ref('bronze_customer') }}
    where first_name is not null      -- ← clean here, isolated
),

-- final join — clean and readable
final as(
    select
        s.sales_id,
        s.quantity,
        s.unit_price,
        s.total_amount,
        st.store_name,
        st.region,
        c.first_name
    from sales s
    left join stores st
        on s.store_sk = st.store_sk
    left join customers c
        on s.customer_sk = c.customer_sk
)
select * from final


