// Navigation hamburger menu
document.addEventListener('DOMContentLoaded', () => {
    // Add animation classes on page load
    setTimeout(() => {
        document.body.classList.add('loaded');
    }, 100);
    
    const hamburger = document.querySelector('.hamburger');
    const navLinks = document.querySelector('.nav-links');

    hamburger.addEventListener('click', () => {
        hamburger.classList.toggle('active');
        navLinks.classList.toggle('active');
    });

    // Close navbar when a link is clicked
    document.querySelectorAll('.nav-links a').forEach(link => {
        link.addEventListener('click', () => {
            hamburger.classList.remove('active');
            navLinks.classList.remove('active');
        });
    });

    // Initialize clipboard.js
    const clipboardBtns = document.querySelectorAll('.copy-btn');
    if (clipboardBtns.length > 0) {
        new ClipboardJS('.copy-btn');
        
        clipboardBtns.forEach(btn => {
            btn.addEventListener('click', () => {
                const originalText = btn.innerHTML;
                btn.innerHTML = '<i class="fas fa-check"></i>';
                
                setTimeout(() => {
                    btn.innerHTML = originalText;
                }, 1500);
            });
        });
    }

    // Carousel for screenshots
    const screenshots = document.querySelectorAll('.screenshot');
    const dots = document.querySelectorAll('.dot');
    const prevBtn = document.querySelector('.prev');
    const nextBtn = document.querySelector('.next');
    
    if (screenshots.length > 0) {
        let currentIndex = 0;
        
        const showScreenshot = (index) => {
            screenshots.forEach(slide => slide.classList.remove('active'));
            dots.forEach(dot => dot.classList.remove('active'));
            
            screenshots[index].classList.add('active');
            dots[index].classList.add('active');
        };
        
        const nextScreenshot = () => {
            currentIndex = (currentIndex + 1) % screenshots.length;
            showScreenshot(currentIndex);
        };
        
        const prevScreenshot = () => {
            currentIndex = (currentIndex - 1 + screenshots.length) % screenshots.length;
            showScreenshot(currentIndex);
        };
        
        // Event listeners for navigation
        prevBtn.addEventListener('click', prevScreenshot);
        nextBtn.addEventListener('click', nextScreenshot);
        
        // Event listeners for dots
        dots.forEach(dot => {
            dot.addEventListener('click', () => {
                const index = parseInt(dot.dataset.index);
                currentIndex = index;
                showScreenshot(currentIndex);
            });
        });
        
        // Auto advance every 5 seconds
        setInterval(nextScreenshot, 5000);
    }

    // Smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                const headerOffset = 80;
                const elementPosition = target.getBoundingClientRect().top;
                const offsetPosition = elementPosition + window.pageYOffset - headerOffset;
                
                window.scrollTo({
                    top: offsetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });

    // Navbar background change on scroll
    const navbar = document.querySelector('.navbar');
    
    window.addEventListener('scroll', () => {
        if (window.scrollY > 100) {
            navbar.style.backgroundColor = 'rgba(255, 255, 255, 0.97)';
            navbar.style.boxShadow = '0 4px 20px rgba(0, 0, 0, 0.1)';
        } else {
            navbar.style.backgroundColor = 'rgba(255, 255, 255, 0.9)';
            navbar.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.1)';
        }
    });    // Animation on scroll
    const animateOnScroll = () => {
        const elements = document.querySelectorAll('.feature-card, .step, .team-member, .tech-badge, .pill');
        
        elements.forEach(element => {
            const elementTop = element.getBoundingClientRect().top;
            const windowHeight = window.innerHeight;
            
            if (elementTop < windowHeight - 80) {
                element.classList.add('animate-in');
            }
        });
    };
    
    // Initial setup for animation
    const setupAnimations = () => {
        const elements = document.querySelectorAll('.feature-card, .step, .team-member');
        
        elements.forEach((element, index) => {
            element.style.opacity = '0';
            element.style.transform = 'translateY(20px)';
            element.style.transition = `opacity 0.5s ease ${index * 0.1}s, transform 0.5s ease ${index * 0.1}s`;
        });
        
        // Add dynamic hover effect to pills
        const pills = document.querySelectorAll('.pill');
        pills.forEach(pill => {
            pill.addEventListener('mouseenter', () => {
                const icon = pill.querySelector('i');
                if (icon) {
                    icon.classList.add('fa-beat');
                    setTimeout(() => {
                        icon.classList.remove('fa-beat');
                    }, 1000);
                }
            });
        });
    };
      setupAnimations();
    window.addEventListener('scroll', animateOnScroll);
    animateOnScroll(); // Run once on page load
    
    // Scroll to top button functionality
    const scrollToTopButton = document.getElementById('scrollToTop');
    
    if (scrollToTopButton) {
        window.addEventListener('scroll', () => {
            if (window.pageYOffset > 300) {
                scrollToTopButton.classList.add('visible');
            } else {
                scrollToTopButton.classList.remove('visible');
            }
        });
        
        scrollToTopButton.addEventListener('click', () => {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        });
    }
});
