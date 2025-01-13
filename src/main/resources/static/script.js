document.addEventListener('DOMContentLoaded', function () {
    const products = [
        { id: 1, name: 'Product 1', price: '$100' },
        { id: 2, name: 'Product 2', price: '$150' },
        { id: 3, name: 'Product 3', price: '$200' },
    ];

    const productsContainer = document.querySelector('.products');
    products.forEach(product => {
        const productElement = document.createElement('div');
        productElement.innerHTML = `
            <h3>${product.name}</h3>
            <p>Price: ${product.price}</p>
            <button class="add-to-cart">Add to Cart</button>
        `;
        productsContainer.appendChild(productElement);
    });
});
