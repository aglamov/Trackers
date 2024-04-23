//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 23.04.2024.
//

import Foundation
import UIKit

class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    private var pages = [UIViewController]()
    private var pageControl = UIPageControl()
    private var timer: Timer?
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        for subview in view.subviews {
            if let scrollView = subview as? UIScrollView {
                scrollView.delegate = self
            }
        }
        
        let firstPage = OnboardingViewController()
        firstPage.labelText = "Отслеживайте только то, что хотите"
        firstPage.imageName = "1"
        let secondPage = OnboardingViewController()
        secondPage.labelText = "Даже если это не литры воды и йога"
        secondPage.imageName = "2"
        let thirdPage = OnboardingViewController()
        thirdPage.labelText = ""
        thirdPage.imageName = ""
        
        pages = [firstPage, secondPage]
        
        if let firstViewController = pages.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.gray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -168)
        ])
        startAutoScrolling()
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard pages.count > previousIndex else {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return nil
        }
        
        guard pages.count > nextIndex else {
            return nil
        }
        
        return pages[nextIndex]
    }

    func startAutoScrolling() {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(scrollToNextPage), userInfo: nil, repeats: true)
    }
    
    func updateCurrentPage() {
        guard let currentViewController = viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentViewController) else {
            return
        }
        pageControl.currentPage = currentIndex
    }
    
    @objc private func scrollToNextPage() {
        guard let currentViewController = viewControllers?.first,
              let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: currentViewController)
        else {
            return
        }
        
        setViewControllers([nextViewController], direction: .forward, animated: true) { [weak self] _ in
            self?.updateCurrentPage()
            
            // Установка задержки в 3 секунды перед вызовом showTabBar()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if let nextPageIndex = self?.pages.firstIndex(of: nextViewController), nextPageIndex == (self?.pages.count ?? 0) - 1 {
                    self?.showTabBar()
                }
            }
        }
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoScrolling()
    }

    func stopAutoScrolling() {
        timer?.invalidate()
        timer = nil
    }

    func showTabBar() {
        let tabBarViewController = TabBarController()
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.pushViewController(tabBarViewController, animated: true)
    }
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            guard let currentViewController = pageViewController.viewControllers?.first,
                  let currentIndex = pages.firstIndex(of: currentViewController) else {
                return
            }
            pageControl.currentPage = currentIndex
        }
    }
}

extension OnboardingPageViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        stopAutoScrolling()
        guard let currentViewController = viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentViewController) else {
            return
        }

        if velocity.x > 0 && currentIndex == pages.count - 1 {
            showTabBar()
        }
    }
}
