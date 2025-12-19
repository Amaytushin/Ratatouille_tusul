from django.db.models import Avg
from rest_framework import viewsets, status
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework import generics, permissions

from .models import *
from .serializer import *

class RecipeCreateView(generics.CreateAPIView):
    queryset = Recipe.objects.all()
    serializer_class = RecipeSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)
        
# 🔹 Recipe ViewSet
class RecipeViewSet(viewsets.ModelViewSet):
    queryset = Recipe.objects.all().annotate(
        avg_rating=Avg('ratings__rating')
    ).order_by('-avg_rating', '-created_at')

    serializer_class = RecipeSerializer
    parser_classes = [MultiPartParser, FormParser]

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsAuthenticated()]
        return [AllowAny()]

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)

    @action(detail=False, methods=['get'])
    def by_category(self, request):
        category = request.query_params.get("category")
        qs = self.queryset
        if category:
            qs = qs.filter(category__name=category)
        serializer = self.get_serializer(qs, many=True)
        return Response(serializer.data)


# 🔹 Category ViewSet
class CategoryViewSet(viewsets.ModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer

# 🔹 Search Recipes API
@api_view(['POST'])
def search_recipes(request):
    """
    Хэрэглэгчийн орцуудыг авч тухайн орцуудыг агуулсан recipe-г буцаах
    """
    selected_ingredients = request.data.get('ingredients', [])
    if not selected_ingredients:
        return Response({"recipes": []})

    recipes = Recipe.objects.filter(
        ingredients__name__in=selected_ingredients
    ).distinct()

    serializer = RecipeSerializer(recipes, many=True, context={'request': request})
    print(serializer.data)
    return Response(serializer.data)

# 🔹 User ViewSet
class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    parser_classes = (MultiPartParser, FormParser)

    def get_permissions(self):
        if self.action == "create":
            return [AllowAny()]           # register → нээлттэй
        if self.action in ["me", "me_update"]:
            return [IsAuthenticated()]    # зөвхөн login хэрэглэгч
        return [IsAuthenticated()]

    def get_serializer_class(self):
        if self.action == "create":
            return UserCreateSerializer
        if self.action in ["me_update", "update", "partial_update"]:
            return UserUpdateSerializer
        return UserSerializer

    # GET /users/me/
    @action(detail=False, methods=["get"])
    def me(self, request):
        serializer = UserSerializer(request.user, context={"request": request})
        return Response(serializer.data)

    # PATCH /users/me_update/
    @action(detail=False, methods=["patch", "put"])
    def me_update(self, request):
        serializer = UserUpdateSerializer(
            request.user,
            data=request.data,
            partial=True,
            context={"request": request}
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(UserSerializer(request.user, context={"request": request}).data)

# 🔹 Ingredient ViewSet
class IngredientViewSet(viewsets.ModelViewSet):
    queryset = Ingredient.objects.all()
    serializer_class = IngredientSerializer

    # 🔹 Wishlist ViewSet
class WishlistViewSet(viewsets.ModelViewSet):
    queryset = Wishlist.objects.all()
    serializer_class = WishlistSerializer
    permission_classes = [IsAuthenticated]

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def my_wishlist(request):
    wishlist = Wishlist.objects.filter(user=request.user)
    serializer = WishlistSerializer(wishlist, many=True, context={'request': request})
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_wishlist(request):
    recipe_id = request.data.get("recipe_id")
    recipe = Recipe.objects.get(id=recipe_id)
    item, _ = Wishlist.objects.get_or_create(user=request.user, recipe=recipe)
    return Response(WishlistSerializer(item).data, status=201)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def remove_wishlist(request, pk):
    Wishlist.objects.filter(id=pk, user=request.user).delete()
    return Response(status=204)



# 🔹 Nutrition ViewSet
class NutritionViewSet(viewsets.ModelViewSet):
    queryset = Nutrition.objects.all()
    serializer_class = NutritionSerializer

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def my_wishlist(request):
    user = request.user
    wishlist = Wishlist.objects.filter(user=user)
    serializer = WishlistSerializer(wishlist, many=True)
    return Response(serializer.data)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_wishlist(request):
    user = request.user
    recipe_id = request.data.get("recipe_id")
    if not recipe_id:
        return Response({"error": "recipe_id is required"}, status=status.HTTP_400_BAD_REQUEST)
    
    recipe = Recipe.objects.get(id=recipe_id)
    wishlist_item, created = Wishlist.objects.get_or_create(user=user, recipe=recipe)
    serializer = WishlistSerializer(wishlist_item)
    return Response(serializer.data, status=status.HTTP_201_CREATED)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def remove_wishlist(request, pk):
    user = request.user
    try:
        wishlist_item = Wishlist.objects.get(id=pk, user=user)
        wishlist_item.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
    except Wishlist.DoesNotExist:
        return Response({"error": "Not found"}, status=status.HTTP_404_NOT_FOUND)
    
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def rate_recipe(request):
    recipe_id = request.data.get("recipe_id")
    rating = request.data.get("rating")

    recipe = Recipe.objects.get(id=recipe_id)

    obj, _ = RecipeRating.objects.update_or_create(
        user=request.user,
        recipe=recipe,
        defaults={"rating": rating}
    )

    return Response({"rating": obj.rating})
